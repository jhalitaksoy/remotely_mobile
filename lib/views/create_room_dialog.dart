import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EnterValueDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String cancelText;
  final String okText;

  final Function(String text) onValueEnter;

  final Function() onCancel;

  const EnterValueDialog(
      {Key key,
      @required this.title,
      @required this.hint,
      this.okText = "Tamamla",
      this.cancelText = "İptal",
      @required this.onValueEnter,
      @required this.onCancel})
      : super(key: key);

  @override
  _EnterValueDialogState createState() => _EnterValueDialogState();
}

class _EnterValueDialogState extends State<EnterValueDialog> {
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
      child: Column(
        children: <Widget>[
          buildTittle(),
          SizedBox(height: 20),
          buildTextField(),
          SizedBox(height: 10),
          buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget buildTittle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextFormField buildTextField() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "This field cannot be empty!";
        }
        return null;
      },
      onChanged: (value) => projeName = value,
      decoration: InputDecoration(
          labelText: widget.hint,
          contentPadding: EdgeInsets.only(left: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  Widget buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        buildRaisedButton(
          widget.cancelText,
          widget.onCancel,
          color: Colors.grey,
        ),
        buildRaisedButton(
          widget.okText,
          () => widget.onValueEnter(projeName),
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  ElevatedButton buildRaisedButton(
    String text,
    Function() onClick, {
    Color color = Colors.blue,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton(
      style: ButtonStyle(),
      child: Text(text, style: TextStyle(color: textColor)),
      onPressed: onClick,
    );
  }
}
