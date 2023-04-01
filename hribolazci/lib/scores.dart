import "package:flutter/material.dart";

import "globals.dart";

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  final String title = "Hribolazci";

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            navigatorKey.currentState?.pop();
          },
        ),
        title: const Text("Scores"),
      ),
      body: const Center(
        child: Text("Scores"),
      ),
    );
  }

  @override
  initState() {
    super.initState();
  }
}