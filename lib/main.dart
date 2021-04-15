import 'package:flutter/material.dart';
import 'package:remotely_mobile/consts/consts.dart';
import 'package:remotely_mobile/views/loginregister/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      initialRoute: Routes.LoginRegisterRoute,
      routes: {
        Routes.LoginRegisterRoute: (context) => LoginRegisterPage(),
      },
    );
  }
}
