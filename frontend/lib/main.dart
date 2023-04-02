import "package:flutter/material.dart";

import "globals.dart";
import "login.dart";
import "map.dart";

enum AppState {initialising, tologin, tomain}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Hribolazci",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
      navigatorKey: navigatorKey
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  final String title = "Hribolazci";

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  AppState state = AppState.initialising;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case AppState.initialising:
        return Container(
          color: Colors.white,
          child: const Center(
            child: DefaultTextStyle(style: TextStyle(color: Colors.blue, fontSize: 50), child: Text("Hribolazci"))
          )
        );
      case AppState.tologin:
        return const LoginPage();
      case AppState.tomain:
        return const MapPage();
    }
  }

  initAuth() async {
    await authStore.init();
    if (authStore.jwtValid()) {
      setState(() {
        state = AppState.tomain;
      });
    } else {
      setState(() {
        state = AppState.tologin;
      });
    }
  }

  @override
  initState() {
    super.initState();
    initAuth();
  }
}
