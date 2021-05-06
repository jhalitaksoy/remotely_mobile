import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remotely_mobile/rtmt/message_encode_decode.dart';
import 'package:remotely_mobile/rtmt/rtmt.dart';

class RealtimeMessageTransportDataChannel extends RealtimeMessageTransport {
  Map<String, OnMessage> channels = <String, OnMessage>{};

  RTCDataChannel _dataChannel;

  void send(String channel, Uint8List message) {
    assert(_dataChannel != null);
    final data = encode(channel, message);
    _dataChannel.send(RTCDataChannelMessage.fromBinary(data));
  }

  void listen(String channel, OnMessage onMessage) {
    channels[channel] = onMessage;
  }

  void setDataChannel(RTCDataChannel dataChannel) {
    _dataChannel = dataChannel;
    _dataChannel.onMessage = _onMessage;
  }

  void _onMessage(RTCDataChannelMessage message) {
    final channelAndMessage = decode(message.binary);
    final callback = channels[channelAndMessage.channel];
    if (callback == null) {
      print("Callnback not found! channel : " + channelAndMessage.channel);
      return;
    }
    callback(channelAndMessage.message);
  }
}
