import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:remotely_mobile/consts/consts.dart';
import 'package:remotely_mobile/main.dart';
import 'package:remotely_mobile/models/room.dart';
import 'package:remotely_mobile/views/create_room_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ThemeData get _theme => Theme.of(context);

  Size get _size => MediaQuery.of(context).size;

  List<Room> rooms = List<Room>();

  Future<List<Room>> futureRooms;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool showCreateRoomDialog = false;

  void onCreateRoom() async {
    setState(() {
      showCreateRoomDialog = true;
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void onRoomSelected(Room room) {
    Routes.navigateRoompage(context, room);
  }

  void onProfileButtonPress() {
    myContext.jwtStore.delete();
    myContext.hasJwtKey = false;
    Navigator.of(context).pushReplacementNamed(Routes.LoginRegisterRoute);
  }

  @override
  void initState() {
    futureRooms = myContext.roomService.listRooms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: buildBody(),
        appBar: buildAppBar(),
        floatingActionButton: buildFloatingActionButton(),
      ),
    );
  }

  Widget buildBody() {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: buildYourRoomsCard()),
          ],
        ),
        if (showCreateRoomDialog) buildCreateRoomDialog()
      ],
    );
  }

  Card buildYourRoomsCard() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text("Your Rooms", style: _theme.textTheme.headline6),
            ),
            buildRooms(),
          ],
        ),
      ),
    );
  }

  Widget buildRooms() {
    return FutureBuilder(
      future: futureRooms,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          rooms = snapshot.data;
          if (rooms.isEmpty) {
            return SizedBox(
              height: _size.height * 0.2,
              child: Center(
                child: Text("Empty"),
              ),
            );
          } else {
            return Flexible(
              fit: FlexFit.loose,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return buildListItem(room);
                },
              ),
            );
          }
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: _size.height * 0.2,
            child: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        return SizedBox(
          height: _size.height * 0.2,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget buildListItem(Room room) {
    return ListTile(
      leading: Icon(Icons.image),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            room.name,
            style: _theme.textTheme.subtitle1,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          )
        ],
      ),
      onTap: () {
        onRoomSelected(room);
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("HomePage"),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle_rounded),
          onPressed: onProfileButtonPress,
        )
      ],
    );
  }

  FloatingActionButton buildFloatingActionButton() {
    return FloatingActionButton(
      child: Icon(
        Icons.create,
        color: _theme.colorScheme.onPrimary,
      ),
      backgroundColor: _theme.primaryColor,
      onPressed: onCreateRoom,
    );
  }

  Widget buildCreateRoomDialog() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CreateRoomDialog(
            onCreateProject: (projectName) async {
              try {
                final result =
                    await myContext.roomService.createRoom(Room(projectName));
                if (result) {
                  showInSnackBar("Created Succesfully");
                  setState(() {
                    futureRooms = myContext.roomService.listRooms();
                    showCreateRoomDialog = false;
                  });
                } else {
                  showInSnackBar("Internal Error");
                }
              } catch (e) {
                print(e);
                showInSnackBar(e.toString());
              }
            },
            onCancel: () {
              setState(() {
                showCreateRoomDialog = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
