import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:remotely_mobile/models/survey.dart';

class SurveyCard extends StatefulWidget {
  final Survey survey;

  SurveyCard(this.survey);

  @override
  _SurveyCardState createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  Survey get survey => widget.survey;

  ThemeData get _theme => Theme.of(context);

  Option option;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Text(
            survey.text,
            style: _theme.textTheme.headline6,
          ),
          ...buildOptions(),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {},
              child: Text("Vote"),
            ),
          )
        ]),
      ),
    );
  }

  List<Widget> buildOptions() {
    return survey.options
        .map<Widget>(
          (e) => RadioListTile<Option>(
            dense: true,
            groupValue: option,
            value: e,
            onChanged: (value) => setState(
              () {
                option = value;
              },
            ),
            title: Text(e.text),
          ),
        )
        .toList();
  }
}
