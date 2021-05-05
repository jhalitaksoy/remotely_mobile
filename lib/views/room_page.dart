import 'package:flutter/material.dart';
import 'package:remotely_mobile/loopback_sample.dart';
import 'package:remotely_mobile/models/room.dart';

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

  _RoomPageState(this.room);

  @override
  void initState() {
    //controller.makeCall();
    super.initState();
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
            Flexible(flex: 2, child: LoopBackSample(controller: controller)),
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
              flex: 1,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Chat",
                    style: _theme.textTheme.headline5,
                  )),
            ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: TextFormField(
                      decoration: InputDecoration(hintText: "Your Message"),
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child:
                          IconButton(icon: Icon(Icons.send), onPressed: null))
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
