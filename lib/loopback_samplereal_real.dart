import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remotely_mobile/main.dart';
import 'package:remotely_mobile/rtmt/message_encode_decode.dart';
import 'package:remotely_mobile/rtmt/rtmt_datachannel.dart';
import 'package:remotely_mobile/util.dart';

import 'models/room.dart';

class WebRTCController {
  _MyAppState state;
  bool inCalling = false;

  void makeCall() {
    _checkStateIsNull();
    try {
      state._makeCall();
    } catch (e) {
      print(e);
    }
  }

  void hangUp() {
    _checkStateIsNull();
    state._hangUp();
  }

  void _checkStateIsNull() {
    if (state == null) {
      throw new Exception("State cannot be null!");
    }
  }
}

class LoopBackSample extends StatefulWidget {
  static String tag = 'loopback_sample';

  final WebRTCController controller;

  final Room room;

  LoopBackSample(
    this.room, {
    this.controller,
  });

  @override
  _MyAppState createState() {
    final state = _MyAppState(controller);
    return state;
  }
}

class _MyAppState extends State<LoopBackSample> {
  MediaStream _localStream;

  RTCPeerConnection _peerConnection;

  final _localRenderer = RTCVideoRenderer();

  final _remoteRenderer = RTCVideoRenderer();

  WebRTCController controller;

  Timer _timer;

  List<String> logs = List<String>();

  _MyAppState(this.controller) {
    if (controller == null) {
      controller = WebRTCController();
    }
    controller.state = this;
  }

  String get sdpSemantics =>
      WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (controller.inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void handleStatsReport(Timer timer) async {
    if (_peerConnection != null) {}
  }

  void _print(Object object) {
    logs.add(object.toString());
    setState(() {
      logs = logs;
    });
  }

  void _onSignalingState(RTCSignalingState state) {
    _print(state);
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    _print(state);
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    _print(state);
  }

  void _onPeerConnectionState(RTCPeerConnectionState state) {
    _print(state);
  }

  void _onAddStream(MediaStream stream) {
    _print('New stream: ' + stream.id);
    _remoteRenderer.srcObject = stream;
  }

  void _onRemoveStream(MediaStream stream) {
    _remoteRenderer.srcObject = null;
  }

  void _onCandidate(RTCIceCandidate candidate) {
    if (candidate == null) {
      _print('onCandidate: complete!');
      return;
    }
    _print('onCandidate: ' + candidate.candidate);
    _peerConnection.addCandidate(candidate);
  }

  void _onTrack(RTCTrackEvent event) {
    _print('onTrack');
    if (event.track.kind == 'video' && event.streams.isNotEmpty) {
      _print('New stream: ' + event.streams[0].id);
      _remoteRenderer.srcObject = event.streams[0];
    }
  }

  void _onRenegotiationNeeded() {
    _print('RenegotiationNeeded');
  }

  RTCDataChannelInit _dataChannelDict;
  RTCDataChannel _dataChannel;

  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      /*'video': {
        'mandatory': {
          'minWidth':
              '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }*/
    };

    var configuration = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': sdpSemantics
    };

    final offerSdpConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
      //'sdpSemantics': 'uinified-plan'
    };

    final loopbackConstraints = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
      //'sdpSemantics': 'uinified-plan'
    };

    if (_peerConnection != null) return;

    _peerConnection =
        await createPeerConnection(configuration, loopbackConstraints);

    _peerConnection.onSignalingState = _onSignalingState;
    _peerConnection.onIceGatheringState = _onIceGatheringState;
    _peerConnection.onIceConnectionState = _onIceConnectionState;
    _peerConnection.onConnectionState = _onPeerConnectionState;
    _peerConnection.onAddStream = _onAddStream;
    _peerConnection.onRemoveStream = _onRemoveStream;
    _peerConnection.onIceCandidate = _onCandidate;
    _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

    _dataChannelDict = RTCDataChannelInit();
    _dataChannelDict.id = 1;
    _dataChannelDict.ordered = true;
    _dataChannelDict.maxRetransmitTime = -1;
    _dataChannelDict.maxRetransmits = -1;
    _dataChannelDict.protocol = 'sctp';
    _dataChannelDict.negotiated = false;

    _dataChannel = await _peerConnection.createDataChannel(
        'dataChannel', _dataChannelDict);

    if (myContext.rtmt is RealtimeMessageTransportDataChannel) {
      (myContext.rtmt as RealtimeMessageTransportDataChannel)
          .setDataChannel(_dataChannel);
      myContext.rtmt.send("channel", stringToBytes("text"));
    } else {
      _print("myContext.rtmt is not RealtimeMessageTransportDataChannel");
    }

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;

    switch (sdpSemantics) {
      case 'plan-b':
        await _peerConnection.addStream(_localStream);
        break;
      case 'unified-plan':
        _peerConnection.onTrack = _onTrack;
        _localStream.getTracks().forEach((track) {
          _peerConnection.addTrack(track, _localStream);
        });
        break;
    }

    var description = await _peerConnection.createOffer(offerSdpConstraints);
    _print("description.sdp");
    await _peerConnection.setLocalDescription(description);

    //change for loopback.
    final sdp = await getRemoteSdp(widget.room.id.toString(), description);
    description.type = 'answer';
    description.sdp = sdp.sdp;
    await _peerConnection.setRemoteDescription(description);

    /*var description = await _peerConnection.createOffer(offerSdpConstraints);
      var sdp = description.sdp;
      _print('sdp = $sdp');
      await _peerConnection.setLocalDescription(description);
      //change for loopback.
      final sd = await getRemoteSdp(description);
      description.type = 'answer';
      description.sdp = sd.sdp;
      await _peerConnection.setRemoteDescription(description);*/

    /* Unfied-Plan replaceTrack
      var stream = await MediaDevices.getDisplayMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      await transceiver.sender.replaceTrack(stream.getVideoTracks()[0]);
      // do re-negotiation ....
      */

    //if (!mounted) return;

    _timer = Timer.periodic(Duration(seconds: 1), handleStatsReport);

    setState(() {
      controller.inCalling = true;
    });
  }

  void _hangUp() async {
    try {
      await _localStream.dispose();
      await _peerConnection.close();
      _peerConnection = null;
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
    } catch (e) {
      _print(e.toString());
    }
    setState(() {
      controller.inCalling = false;
    });
    _timer.cancel();
  }

  void _sendDtmf() async {
    var dtmfSender =
        _peerConnection.createDtmfSender(_localStream.getAudioTracks()[0]);
    await dtmfSender.insertDTMF('123#');
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      /*Expanded(
        child: RTCVideoView(_localRenderer, mirror: true),
      ),*/
      Expanded(
        child: RTCVideoView(_remoteRenderer),
      )
    ];

    return Stack(
      children: [
        RTCVideoView(_remoteRenderer),
        /*Container(
          color: Colors.black,
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              return Text(
                logs[index],
                style: TextStyle(color: Colors.white),
              );
            },
          ),
        ),*/
      ],
    );
  }
}
