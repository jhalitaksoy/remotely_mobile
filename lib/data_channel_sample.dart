import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remotely_mobile/util.dart';

class DataChannelSample extends StatefulWidget {
  static String tag = 'data_channel_sample';

  @override
  _DataChannelSampleState createState() => _DataChannelSampleState();
}

class _DataChannelSampleState extends State<DataChannelSample> {
  RTCPeerConnection _peerConnection;
  bool _inCalling = false;

  RTCDataChannelInit _dataChannelDict;
  RTCDataChannel _dataChannel;

  String _sdp;

  @override
  void initState() {
    super.initState();
  }

  void _onSignalingState(RTCSignalingState state) {
    print(state);
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    print(state);
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    print(state);
  }

  void _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ' + candidate.candidate);
    _peerConnection.addCandidate(candidate);
    setState(() {
      _sdp += '\n';
      _sdp += candidate.candidate;
    });
  }

  void _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
  }

  /// Send some sample messages and handle incoming messages.
  void _onDataChannel(RTCDataChannel dataChannel) {
    print("OnDataChannel ********");
    dataChannel.onMessage = (message) {
      if (message.type == MessageType.text) {
        print(message.text);
      } else {
        // do something with message.binary
      }
    };
    // or alternatively:
    dataChannel.messageStream.listen((message) {
      if (message.type == MessageType.text) {
        print(message.text);
      } else {
        // do something with message.binary
      }
    });

    dataChannel.send(RTCDataChannelMessage('Hello!'));
    dataChannel.send(RTCDataChannelMessage.fromBinary(Uint8List(5)));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    var configuration = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ]
    };

    final offerSdpConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': false,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    final loopbackConstraints = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    if (_peerConnection != null) return;

    _peerConnection =
        await createPeerConnection(configuration, loopbackConstraints);

    _peerConnection.onSignalingState = _onSignalingState;
    _peerConnection.onIceGatheringState = _onIceGatheringState;
    _peerConnection.onIceConnectionState = _onIceConnectionState;
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

    _dataChannel.onMessage = (RTCDataChannelMessage data) {
      print(data.text);
    };
    _peerConnection.onDataChannel = _onDataChannel;

    var description = await _peerConnection.createOffer(offerSdpConstraints);
    print(description.sdp);
    await _peerConnection.setLocalDescription(description);

    _sdp = description.sdp;
    //change for loopback.
    final sdp = await getRemoteSdp("0", description);
    description.type = 'answer';
    description.sdp = sdp.sdp;
    _peerConnection.setRemoteDescription(description);

    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _hangUp() async {
    try {
      await _dataChannel.close();
      await _peerConnection.close();
      _peerConnection = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Channel Test'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              child: _inCalling ? Text(_sdp) : Text('data channel test'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
