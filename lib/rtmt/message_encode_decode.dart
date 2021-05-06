import 'dart:typed_data';

const headerLenght = 4;
Uint8List encode(String channel, Uint8List message) {
  final channelLenght = channel.length;
  final messageLenght = message.length;
  final totalLenght = headerLenght + channelLenght + messageLenght;

  final byteData = ByteData(totalLenght);

  byteData.setUint32(0, channelLenght);

  final channelBytes = stringToBytes(channel);

  var count = headerLenght;
  for (final byte in channelBytes) {
    byteData.setUint8(count, byte);
    count++;
  }

  for (final byte in message) {
    byteData.setUint8(count, byte);
    count++;
  }

  return byteData.buffer.asUint8List();
}

class ChannelAndMessage {
  String channel;
  Uint8List message;
  ChannelAndMessage(this.channel, this.message);
}

ChannelAndMessage decode(Uint8List bytes) {
  final byteData = ByteData.sublistView(bytes);

  final channelLenght = byteData.getUint32(0, Endian.big);

  final channel = bytesToString(bytes.sublist(
    headerLenght,
    headerLenght + channelLenght,
  ));

  final message = bytes.sublist(headerLenght + channelLenght);

  return ChannelAndMessage(channel, message);
}

Uint8List stringToBytes(String text) {
  List<int> list = text.codeUnits;
  return Uint8List.fromList(list);
}

String bytesToString(Uint8List bytes) {
  return String.fromCharCodes(bytes);
}
