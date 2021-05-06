import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:remotely_mobile/loopback_samplereal_real.dart';
import 'package:remotely_mobile/main.dart';
import 'package:remotely_mobile/models/room.dart';
import 'package:remotely_mobile/models/room_chat.dart';
import 'package:remotely_mobile/rtmt/message_encode_decode.dart';

const CHANNEL_CHAT = "chat";

class RoomPage extends StatefulWidget {
  final Room room;

  RoomPage(this.room);
  @override
  _RoomPageState createState() => _RoomPageState(room);
}

class _RoomPageState extends State<RoomPage> {
  final Room room;
  ThemeData get _theme => Theme.of(context);

  Size get _size => MediaQuery.of(context).size;
  WebRTCController controller = WebRTCController();

  List<ChatMessage> chatMessages = List<ChatMessage>();

  TextEditingController chatTextController = TextEditingController();

  _RoomPageState(this.room);

  @override
  void initState() {
    //controller.makeCall();
    myContext.rtmt.listen(CHANNEL_CHAT, onChatMessage);
    super.initState();
  }

  void onChatMessage(Uint8List data) {
    final chatMessageStr = bytesToString(data);
    final chatMessage = ChatMessage.fromJson(jsonDecode(chatMessageStr));
    chatMessages.add(chatMessage);
    setState(() {
      chatMessages = chatMessages;
    });
  }

  void sendChatMessage() {
    final text = chatTextController.text;
    chatTextController.clear();
    final chatMessage = ChatMessage(text: text);
    final json = jsonEncode(chatMessage);
    myContext.rtmt.send(CHANNEL_CHAT, stringToBytes(json));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(room.name),
          actions: [buildmakeCallButton()],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                flex: 2, child: LoopBackSample(room, controller: controller)),
            Flexible(flex: 4, child: buildChatView()),
          ],
        ),
        //floatingActionButton: buildFloatingActionButton(),
      ),
    );
  }

  Card buildChatView() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Chat",
                    style: _theme.textTheme.headline5,
                  )),
            ),
            Expanded(
              flex: 5,
              child: Container(
                child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    final chatMessage = chatMessages[index];
                    return Row(
                      children: [
                        Text(
                          chatMessage.user.name,
                          style: _theme.textTheme.bodyText1,
                        ),
                        SizedBox(width: _size.width * 0.01),
                        Text(chatMessage.text),
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: TextFormField(
                      controller: chatTextController,
                      decoration: InputDecoration(hintText: "Your Message"),
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: IconButton(
                          icon: Icon(Icons.send), onPressed: sendChatMessage))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: controller.inCalling ? controller.hangUp : controller.makeCall,
      tooltip: controller.inCalling ? 'Hangup' : 'Call',
      child: Icon(controller.inCalling ? Icons.call_end : Icons.phone),
    );
  }

  IconButton buildmakeCallButton() {
    return IconButton(
      onPressed: controller.inCalling ? controller.hangUp : controller.makeCall,
      tooltip: controller.inCalling ? 'Hangup' : 'Call',
      icon: Icon(controller.inCalling ? Icons.call_end : Icons.phone),
    );
  }
}
