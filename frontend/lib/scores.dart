import "package:flutter/material.dart";

import "globals.dart";
import "http.dart" as http;

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  final String title = "Hribolazci";

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  List<UserEntry> competitors = [];

  int meIndex = -1;

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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: competitors.isEmpty ? const Center(child: Text("Loading...")) : ListView.builder(
          itemCount: competitors.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#${index + 1}",
                    style: TextStyle(
                      color: index == meIndex ? Colors.grey : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    competitors[index].username,
                    style: TextStyle(
                      color: index == meIndex ? Colors.grey : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "${competitors[index].points} points",
                    style: TextStyle(
                      color: index == meIndex ? Colors.grey : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          },
        )
      )
    );
  }

  getCompetitors() async {
    var response = await http.getUsersInGroup();
    if (response != null) {
      setState(() {
        competitors = response;
        competitors.sort((a, b) => a.points >= b.points ? -1 : 1);
        for (var i = 0; i < competitors.length; i++) {
          final c = competitors[i];
          if (c.id == authStore.user!.id) {
            meIndex = i;
            break;
          }
        }
      });
    }
  }

  @override
  initState() {
    super.initState();
    getCompetitors();
  }
}