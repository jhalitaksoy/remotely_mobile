import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:remotely_mobile/models/survey.dart';

class CreateSurveyDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String cancelText;
  final String okText;

  final Function(Survey survey) onSurveyCreate;

  final Function() onCancel;

  const CreateSurveyDialog(
      {Key key,
      @required this.title,
      @required this.hint,
      this.okText = "Tamamla",
      this.cancelText = "İptal",
      @required this.onSurveyCreate,
      @required this.onCancel})
      : super(key: key);

  @override
  _CreateSurveyDialogState createState() => _CreateSurveyDialogState();
}

class _CreateSurveyDialogState extends State<CreateSurveyDialog> {
  String projeName;
  String optionText;
  ThemeData get _theme => Theme.of(context);

  List<Option> options = <Option>[];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
      ),
    );
  }

  Form buildForm(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildTittle(),
          SizedBox(height: 20),
          buildTextField(),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Options",
              style: _theme.textTheme.headline6,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Chip(
                      label: Text(options[index].text),
                      deleteIcon: Icon(Icons.delete),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                Expanded(child: buildOptionTextField()),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    options.add(Option(text: optionText));
                    setState(() {
                      options = options;
                    });
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ),
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

  TextFormField buildOptionTextField() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "This field cannot be empty!";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          optionText = value;
        });
      },
      decoration: InputDecoration(
          labelText: "Option",
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
          () => widget.onSurveyCreate(Survey()),
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
