import 'package:flutter/material.dart';
import 'package:remotely_mobile/enums/login_mode.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  LoginMode _loginMode = LoginMode.Login;

  String get _title {
    switch (_loginMode) {
      case LoginMode.Login:
        return "Log in";
      case LoginMode.Register:
        return "Sign Up";
      default:
        return "Unkown";
    }
  }

  String get _changeModeButtonText {
    switch (_loginMode) {
      case LoginMode.Register:
        return "Log in";
      case LoginMode.Login:
        return "Sign up";
      default:
        return "Unkown";
    }
  }

  String get _submitButtonText => _title;

  ThemeData get _theme => Theme.of(context);

  Size get _size => MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: buildBody(),
      ),
    );
  }

  void onSignUpClick() {
    LoginMode newMode = _loginMode.switchMode();

    setState(() {
      _loginMode = newMode;
    });
  }

  Widget buildBody() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(_size.height * 0.03),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildIcon(),
                SizedBox(height: _size.height * 0.01),
                buildTittle(),
                SizedBox(height: _size.height * 0.03),
                buildInputArea("User Name"),
                SizedBox(height: _size.height * 0.02),
                buildInputArea("Password", password: true),
                SizedBox(height: _size.height * 0.02),
                if (_loginMode == LoginMode.Register) ...[
                  buildInputArea("Password", password: true),
                  SizedBox(height: _size.height * 0.02),
                ],
                if (_loginMode == LoginMode.Login) ...[
                  buildTextButton("Forgot Password?", null),
                  SizedBox(height: _size.height * 0.01),
                ],
                buildSubmitButton(_submitButtonText),
                SizedBox(height: _size.height * 0.01),
                buildTextButton(_changeModeButtonText, onSignUpClick),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextButton(String text, Function onPressed) {
    return Center(
      child: InkWell(
        onTap: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget buildIcon() {
    return Icon(
      Icons.account_circle,
      size: _size.height * 0.1,
    );
  }

  Widget buildTittle() {
    return Center(
      child: Text(
        _title,
        style: _theme.textTheme.headline4,
      ),
    );
  }

  Widget buildInputArea(String name, {bool password = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          obscureText: password,
          enableSuggestions: !password,
          decoration: InputDecoration(
            isDense: false,
            contentPadding: EdgeInsets.all(_size.height * 0.02),
            hintText: name,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  RaisedButton buildSubmitButton(String text) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () {},
      child: Text(text,
          style: _theme.textTheme.bodyText1.copyWith(
            color: _theme.colorScheme.onPrimary,
          )),
    );
  }
}
