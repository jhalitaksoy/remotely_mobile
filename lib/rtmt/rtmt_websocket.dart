import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remotely_mobile/rtmt/message_encode_decode.dart';
import 'package:remotely_mobile/rtmt/rtmt.dart';
import 'package:web_socket_channel/io.dart';

class RealtimeMessageTransportWS extends RealtimeMessageTransport {
  Map<String, OnMessage> channels = <String, OnMessage>{};

  IOWebSocketChannel webSocket;

  String wsBaseUrl;

  RealtimeMessageTransportWS(this.wsBaseUrl);

  void send(String channel, Uint8List message) {
    assert(webSocket != null);
    final data = encode(channel, message);
    webSocket.sink.add(data);
  }

  void listen(String channel, OnMessage onMessage) {
    channels[channel] = onMessage;
  }

  void init(String roomID, String jwtKey) async {
    try {
      final url = wsBaseUrl + roomID + "?token=" + jwtKey;
      webSocket = IOWebSocketChannel.connect(url);
      print("ws opened");
      await for (final message in webSocket.stream) {
        if (message is Uint8List) {
          _onMessage(message);
        } else {
          print("(rtmt) unknown type! " + message.runtimeType.toString());
        }
      }
      print("ws closed");
      print(webSocket.closeReason);
    } catch (e) {
      print(e);
    }
  }

  void _onMessage(Uint8List data) {
    final channelAndMessage = decode(data);
    final callback = channels[channelAndMessage.channel];
    if (callback == null) {
      print("Callnback not found! channel : " + channelAndMessage.channel);
      return;
    }
    callback(channelAndMessage.message);
  }
}
