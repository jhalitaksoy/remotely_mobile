import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:remotely_mobile/consts/consts.dart';
import 'package:remotely_mobile/context/context.dart';
import 'package:remotely_mobile/main.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  Future<Context> futureContext;

  void onUnauthorized(Response response) {
    Navigator.of(context).pushReplacementNamed(Routes.LoginRegisterRoute);
  }

  void onLoad(Context _myContext) async {
    final jwt = await _myContext.jwtStore.get();
    myContext = _myContext;
    if (jwt == null) {
      Navigator.of(context).pushReplacementNamed(Routes.LoginRegisterRoute);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.HomeRoute);
    }
  }

  @override
  Future<void> initState() {
    futureContext = createContext(onUnauthorized);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: FutureBuilder<Context>(
            future: futureContext,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                onLoad(snapshot.data);
                //return Text("Loaded");
              }

              if (snapshot.hasError) {
                return Text("Internal Error");
              }

              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
