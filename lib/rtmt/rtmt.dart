import 'dart:typed_data';

typedef OnMessage = Function(Uint8List);

abstract class RealtimeMessageTransport {
  void send(String channel, Uint8List message);
  void listen(String channel, OnMessage onMessage);
}
