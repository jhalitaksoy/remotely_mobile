import 'package:flutter/material.dart';
import 'package:remotely_mobile/consts/consts.dart';
import 'package:remotely_mobile/context/context.dart';
import 'package:remotely_mobile/views/home_page.dart';
import 'package:remotely_mobile/views/loading_page.dart';
import 'package:remotely_mobile/views/loginregister/login_page.dart';

Context myContext;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String get initialRoute {
    if (myContext == null) {
      return Routes.LoadingRoute;
    } else {
      if (myContext.hasJwtKey) {
        return Routes.HomeRoute;
      } else {
        return Routes.LoginRegisterRoute;
      }
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFFE3562A),
          colorScheme: ColorScheme.light(onPrimary: Colors.white),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFFE3562A),
            //buttonColor: Color(0xE3562A),
          )),
      //home: DataChannelSample(),
      //home: LoopBackSample(),
      initialRoute: initialRoute,
      routes: {
        Routes.LoginRegisterRoute: (context) => LoginRegisterPage(),
        Routes.HomeRoute: (context) => HomePage(),
        Routes.LoadingRoute: (context) => LoadingPage(),
      },
    );
  }
}
