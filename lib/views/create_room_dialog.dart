import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CreateRoomDialog extends StatefulWidget {
  final Function(String projectName) onCreateProject;

  final Function() onCancel;

  const CreateRoomDialog({Key key, this.onCreateProject, this.onCancel})
      : super(key: key);

  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  String projeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5.0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: buildForm(context),
          ),
        ),
      ],
    );
  }

  Form buildForm(BuildContext context) {
    return Form(
      autovalidate: true,
      child: Column(
        children: <Widget>[
          buildTittle(),
          SizedBox(height: 20),
          buildProjectName(),
          SizedBox(height: 10),
          buildBottomButtons(context),
        ],
      ),
    );
  }

  Row buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        buildRaisedButton("İptal", widget.onCancel, color: Colors.grey),
        buildRaisedButton("Oluştur", () {
          widget.onCreateProject(projeName);
        }, color: Theme.of(context).primaryColor),
      ],
    );
  }

  TextFormField buildProjectName() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "Room name cannot be empty!";
        }
        return null;
      },
      onChanged: (value) => projeName = value,
      decoration: InputDecoration(
          labelText: "Room name",
          contentPadding: EdgeInsets.only(left: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  RaisedButton buildRaisedButton(String text, Function() onClick,
      {Color color = Colors.blue, Color textColor = Colors.white}) {
    return RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: color,
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
        onPressed: onClick);
  }

  Widget buildTittle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Create Room",
        style: TextStyle(
          fontSize: 20,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
