import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remotely_mobile/main.dart';
import 'package:remotely_mobile/rtmt/message_encode_decode.dart';

import 'models/room.dart';

class WebRTCController {
  _MyAppState state;
  bool inCalling = false;

  void makeCall() {
    _checkStateIsNull();
    try {
      //state._makeCall();
    } catch (e) {
      print(e);
    }
  }

  void hangUp() {
    _checkStateIsNull();
    //state._hangUp();
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

const ChannelSDPAnswer = "sdp_answer";
const ChannelSDPOffer = "sdp_offer";
const ChannelICE = "ice";
const ChannelReady = "ready";

class _MyAppState extends State<LoopBackSample> {
  WebRTCController controller;

  final _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  List _remoteRenderers = [];

  RTCPeerConnection _peerConnection;

  _MyAppState(this.controller) {
    if (controller == null) {
      controller = WebRTCController();
    }
    controller.state = this;
  }
  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    _peerConnection =
        await createPeerConnection({"sdpSemantics": 'unified-plan'}, {});

    await _localRenderer.initialize();
    var localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': false});
    _localRenderer.srcObject = localStream;

    localStream.getTracks().forEach((track) async {
      await _peerConnection.addTrack(track, localStream);
    });

    _peerConnection.addTransceiver(kind: RTCRtpMediaType.RTCRtpMediaTypeVideo);

    _peerConnection.onIceCandidate = (candidate) async {
      if (candidate == null) {
        return;
      }

      final json = JsonEncoder().convert({
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      });

      myContext.rtmt.send(ChannelICE, stringToBytes(json));
    };

    myContext.rtmt.listen(ChannelICE, (message) async {
      final jsonText = bytesToString(message);
      final json = jsonDecode(jsonText);

      print(json['candidate']);
      final candidate = json['candidate'];
      if (candidate != null) {
        _peerConnection.addCandidate(RTCIceCandidate(json['candidate'], "", 0));
      }
    });

    _peerConnection.onTrack = (event) async {
      final boolean = event.track.kind == 'video' && event.streams.isNotEmpty;
      print(boolean);
      print(event.track.kind);
      if (boolean) {
        print("inside");
        var renderer = RTCVideoRenderer();
        await renderer.initialize();
        renderer.srcObject = event.streams[0];

        setState(() {
          _remoteRenderer = renderer;
          _remoteRenderers.add(renderer);
        });
      }
    };

    _peerConnection.onRemoveStream = (stream) {
      var rendererToRemove;
      var newRenderList = [];

      // Filter existing renderers for the stream that has been stopped
      _remoteRenderers.forEach((r) {
        if (r.srcObject.id == stream.id) {
          rendererToRemove = r;
        } else {
          newRenderList.add(r);
        }
      });

      // Set the new renderer list
      setState(() {
        _remoteRenderers = newRenderList;
      });

      // Dispose the renderer we are done with
      if (rendererToRemove != null) {
        rendererToRemove.dispose();
      }
    };

    myContext.rtmt.listen(ChannelSDPAnswer, (message) async {
      final sdpText = bytesToString(message);
      final answer = jsonDecode(sdpText);
      await _peerConnection.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']));
    });

    myContext.rtmt.listen(ChannelSDPOffer, (message) async {
      final sdpText = bytesToString(message);
      final offer = jsonDecode(sdpText);
      print(offer);
      await _peerConnection.setRemoteDescription(
          RTCSessionDescription(offer['sdp'], offer['type']));
      RTCSessionDescription answer = await _peerConnection.createAnswer({});
      await _peerConnection.setLocalDescription(answer);
      final json = jsonEncode({
        "sdp": offer.sdp,
        "type": offer.type,
      });

      myContext.rtmt.send(ChannelSDPAnswer, stringToBytes(json));
    });
    //myContext.rtmt.send(ChannelReady, stringToBytes("ready"));

    RTCSessionDescription offer = await _peerConnection.createOffer({});
    await _peerConnection.setLocalDescription(offer);
    final json = jsonEncode({
      "sdp": offer.sdp,
      "type": offer.type,
    });
    myContext.rtmt.send(ChannelSDPOffer, stringToBytes(json));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RTCVideoView(_remoteRenderer),
      ],
    );
  }
}
