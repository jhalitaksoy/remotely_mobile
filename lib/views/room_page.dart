import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:remotely_mobile/components/survey_card.dart';
import 'package:remotely_mobile/loopback_samplereal_real.dart';
import 'package:remotely_mobile/main.dart';
import 'package:remotely_mobile/models/room.dart';
import 'package:remotely_mobile/models/room_chat.dart';
import 'package:remotely_mobile/models/survey.dart';
import 'package:remotely_mobile/rtmt/message_encode_decode.dart';
import 'package:remotely_mobile/views/create_survey_dialog.dart';

const CHANNEL_CHAT = "chat";
const ChannelSurveyCreate = "survey_create";
const ChannelSurveyDestroy = "survey_destroy";
const ChannelSurveyUpdate = "survey_update";
const ChannelSurveyVote = "survey_vote";

class RoomPage extends StatefulWidget {
  final int roomID;

  RoomPage(this.roomID);
  @override
  _RoomPageState createState() => _RoomPageState(this.roomID);
}

class _RoomPageState extends State<RoomPage> {
  final int roomID;

  Room room;

  ThemeData get _theme => Theme.of(context);

  Size get _size => MediaQuery.of(context).size;
  WebRTCController controller = WebRTCController();

  List<ChatMessage> chatMessages = <ChatMessage>[];

  TextEditingController chatTextController = TextEditingController();

  Future<Room> roomFuture;
  Future<List<ChatMessage>> chatFuture;

  List<Survey> surveys = <Survey>[
    /*Survey(
      text: "Test",
      participantCount: 3,
      options: [
        Option(count: 1, text: "a"),
        Option(count: 2, text: "b"),
      ],
    )*/
  ];

  bool showSurveyCreateDialog = false;

  _RoomPageState(this.roomID);

  @override
  void initState() {
    //controller.makeCall();
    myContext.rtmt.listen(CHANNEL_CHAT, onChatMessage);
    myContext.rtmt.listen(ChannelSurveyCreate, onSurveyCreate);
    myContext.rtmt.listen(ChannelSurveyDestroy, onSurveyDestroy);
    roomFuture = myContext.roomService.getRoomById(this.roomID);
    chatFuture = myContext.roomService.getRoomChatMessagesById(this.roomID);
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

  void onSurveyCreate(Uint8List data) {
    final surveyStr = bytesToString(data);
    final survey = Survey.fromJson(jsonDecode(surveyStr));
    surveys.add(survey);
    setState(() {
      surveys = surveys;
    });
  }

  void onSurveyDestroy(Uint8List data) {
    final surveyStr = bytesToString(data);
    final json = jsonDecode(surveyStr);
    final surveyID = json["surveyID"] as int;
    removeSurveyById(surveyID);
  }

  void removeSurveyById(int surveyID) {
    Survey survey;
    for (var _survey in surveys) {
      if (_survey.ID == surveyID) {
        survey = _survey;
        break;
      }
    }
    surveys.remove(survey);
    setState(() {
      surveys = surveys;
    });
  }

  void openSurveyCreaetDialog() {
    setState(() {
      showSurveyCreateDialog = true;
    });
  }

  void onSurveyCreateClick(Survey survey) {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder<Room>(
      future: roomFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          room = snapshot.data;
        }
        return Scaffold(
          appBar: buildAppBar(),
          body: Stack(
            children: [
              buildBody(snapshot),
              if (showSurveyCreateDialog) buildSurveyCreateDialog(),
            ],
          ),
        );
      },
    ));
  }

  Widget buildSurveyCreateDialog() {
    return Center(
      child: CreateSurveyDialog(
        title: "Create Survey",
        hint: "Survey Name",
        onSurveyCreate: onSurveyCreateClick,
        onCancel: () {
          setState(
            () {
              showSurveyCreateDialog = false;
            },
          );
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(room == null ? "" : room.name),
      actions: [
        buildMakeCallButton(),
      ],
    );
  }

  Widget buildBody(AsyncSnapshot<Room> snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text(snapshot.error));
    }

    if (snapshot.hasData) {
      room = snapshot.data;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 2,
            child: LoopBackSample(snapshot.data, controller: controller),
          ),
          Flexible(flex: 4, child: buildChatView()),
        ],
      );
    }
    return Center(child: CircularProgressIndicator());
  }

  Card buildChatView() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildChatTitle(),
            if (surveys.isNotEmpty) SurveyCard(surveys.last),
            buildChatBody(),
            buildChatMessageSender(),
          ],
        ),
      ),
    );
  }

  Flexible buildChatTitle() {
    return Flexible(
      fit: FlexFit.tight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Chat",
            style: _theme.textTheme.headline5,
          ),
          IconButton(
            icon: Icon(Icons.more_vert_outlined),
            onPressed: openSurveyCreaetDialog,
          ),
        ],
      ),
    );
  }

  /*Widget buildSurveys() {
    return Expanded(
      flex: 4,
      child: ListView.builder(
        itemCount: surveys.length,
        itemBuilder: (context, index) {
          final survey = surveys[index];
          return ;
        },
      ),
    );
  }*/

  Expanded buildChatBody() {
    return Expanded(
      flex: 5,
      child: Container(
        child: FutureBuilder<List<ChatMessage>>(
          future: chatFuture,
          builder: (context, snapshot) {
            chatMessages = snapshot.data;
            if (snapshot.hasData) {
              return buildChatListView();
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error));
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Expanded buildChatMessageSender() {
    return Expanded(
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
              icon: Icon(Icons.send),
              onPressed: sendChatMessage,
            ),
          )
        ],
      ),
    );
  }

  ListView buildChatListView() {
    return ListView.builder(
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
    );
  }

  FloatingActionButton buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: controller.inCalling ? controller.hangUp : controller.makeCall,
      tooltip: controller.inCalling ? 'Hangup' : 'Call',
      child: Icon(controller.inCalling ? Icons.call_end : Icons.phone),
    );
  }

  IconButton buildMakeCallButton() {
    return IconButton(
      onPressed: controller.inCalling ? controller.hangUp : controller.makeCall,
      tooltip: controller.inCalling ? 'Hangup' : 'Call',
      icon: Icon(controller.inCalling ? Icons.call_end : Icons.phone),
    );
  }
}
