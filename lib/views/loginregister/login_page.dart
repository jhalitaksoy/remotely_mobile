import 'package:flutter/material.dart';
import 'package:remotely_mobile/consts/consts.dart';
import 'package:remotely_mobile/enums/login_mode.dart';
import 'package:remotely_mobile/main.dart';
import 'package:remotely_mobile/models/auth.dart';

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

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();

  String error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: buildBody(),
      ),
    );
  }

  void onSubmitPressed() {
    switch (_loginMode) {
      case LoginMode.Login:
        onLoginPressed();
        break;
      case LoginMode.Register:
        onRegisterPressed();
        break;
      default:
    }
  }

  void onLoginPressed() async {
    if (nameController.text.isEmpty) {
      setState(() {
        error = "Name cannot be empty!";
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        error = "Password cannot be empty!";
      });
      return;
    }

    final loginParameters = LoginParameters(
      name: nameController.text,
      password: passwordController.text,
    );

    login(loginParameters);
  }

  void login(LoginParameters loginParameters) async {
    try {
      var result = await myContext.authService.login(loginParameters);
      if (!result) {
        setState(() {
          error = "User name or password is wrong!";
        });
      } else {
        Navigator.pushReplacementNamed(context, Routes.HomeRoute);
        clearTextInputs();
      }
    } catch (e) {
      print(e);
      setState(() {
        error = e.toString();
      });
    }
  }

  void onRegisterPressed() async {
    if (nameController.text.isEmpty) {
      setState(() {
        error = "Name cannot be empty!";
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        error = "Password cannot be empty!";
      });
      return;
    }

    if (password2Controller.text.isEmpty) {
      setState(() {
        error = "Password cannot be empty!";
      });
      return;
    }

    if (passwordController.text != password2Controller.text) {
      setState(() {
        error = "Passwords not equal!";
      });
      return;
    }
    final registerParameters = RegisterParameters(
      name: nameController.text,
      password: passwordController.text,
    );
    try {
      var result = await myContext.authService.register(registerParameters);
      if (!result) {
        setState(() {
          error = "User name is not suitable!";
        });
      } else {
        final loginParameters = LoginParameters(
          name: nameController.text,
          password: passwordController.text,
        );

        login(loginParameters);
      }
    } catch (e) {
      print(e);
      setState(() {
        error = e.toString();
      });
    }
  }

  void clearTextInputs() {
    nameController.clear();
    passwordController.clear();
    password2Controller.clear();
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
                buildInputArea("User Name", nameController),
                SizedBox(height: _size.height * 0.02),
                buildInputArea("Password", passwordController, password: true),
                SizedBox(height: _size.height * 0.02),
                if (_loginMode == LoginMode.Register) ...[
                  buildInputArea("Password", password2Controller,
                      password: true),
                  SizedBox(height: _size.height * 0.02),
                ],
                if (error != null) ...[
                  Center(
                      child: Text(
                    error,
                    style: _theme.textTheme.bodyText1,
                  )),
                  SizedBox(height: _size.height * 0.01),
                ],
                if (_loginMode == LoginMode.Login) ...[
                  buildTextButton("Forgot Password?", null),
                  SizedBox(height: _size.height * 0.01),
                ],
                buildSubmitButton(_submitButtonText, onSubmitPressed),
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

  Widget buildInputArea(String name, TextEditingController controller,
      {bool password = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          obscureText: password,
          enableSuggestions: !password,
          controller: controller,
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

  RaisedButton buildSubmitButton(String text, Function onPressed) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: _theme.textTheme.bodyText1.copyWith(
            color: _theme.colorScheme.onPrimary,
          )),
    );
  }
}
