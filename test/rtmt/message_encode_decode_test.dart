import 'package:flutter_test/flutter_test.dart';
import 'package:remotely_mobile/rtmt/message_encode_decode.dart';

void main() {
  test("Message encode decode test ", () async {
    final channel = "channel";
    final message = "message";
    final messageBytes = stringToBytes(message);

    final data = encode(channel, messageBytes);
    final channelAndMessage = decode(data);

    final decodedMessage = bytesToString(channelAndMessage.message);

    expect(decodedMessage, message);
    expect(channelAndMessage.channel, channel);
  });
}
