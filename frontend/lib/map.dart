import "package:flutter/material.dart";


import "package:flutter_map/flutter_map.dart";
import "package:flutter_map/plugin_api.dart";
import "package:hribolazci/globals.dart";
import "package:hribolazci/scores.dart";
import "package:latlong2/latlong.dart";
import "package:geolocator/geolocator.dart";

import "http.dart" as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  final String title = "Hribolazci";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double lat = 46.056946;
  double long = 14.505751;

  bool showAllHills = true;

  List<HillEntry> allHills = [];
  List<HillEntry> flaggedHills = [];
  List<EdgeEntry> edges = [];

  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hribolazci"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(lat, long),
                zoom: 10.0,
              ),
              nonRotatedChildren: [
                AttributionWidget.defaultWidget(
                  source: "OpenStreetMap contributors",
                  onSourceTapped: null,
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "si.fri.hribolazci",
                ),
                CircleLayer(
                  circles: allHills.map((h) => CircleMarker(
                    point: LatLng(h.latitude, h.longitude),
                    radius: 1000,
                    borderStrokeWidth: 2,
                    borderColor: const Color.fromARGB(255, 0, 0, 0),
                    color: const Color.fromARGB(0, 0, 0, 0),
                    useRadiusInMeter: true,
                  )).toList(),
                ),
                PolylineLayer(
                  polylineCulling: true,
                  polylines: drawEdges(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Container(
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      "#4 (3140 points)",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(onPressed: () {
                    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => const ScoresPage()));
                  }, icon: const Icon(Icons.flutter_dash))
                ],
              ),
            )
          ),
        ]
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20 + 10),
        child: FloatingActionButton(
          onPressed: () {
            // TODO
            getAllHills();
            getFlaggedHills();
            getAllEdges();
          },
          tooltip: "Refresh",
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return Future.error("Location permissions are denied");
      }
    }
    
    return await Geolocator.getCurrentPosition();
  }

  updatePosition() async {
    Position position = await _determinePosition();
    lat = position.latitude;
    long = position.longitude;
    _mapController.move(LatLng(lat, long), 10);
  }

  getAllHills() async {
    var response = await http.getAllHills();
    if (response != null) {
      setState(() {
        allHills = response;
      });
    }
  }

  getAllEdges() async {
    var response = await http.getAllEdges();
    if (response != null) {
      setState(() {
        edges = response;
      });
    }
  }

  getFlaggedHills() async {
    var response = await http.getFlaggedHills();
    print("Flagged hills");
    if (response != null) {
      setState(() {
        flaggedHills = response;
        print(flaggedHills);
      });
    }
  }

  HillEntry findHillEntry(String hillId) {
    final list = showAllHills ? allHills : flaggedHills;
    return list.firstWhere((h) => h.id == hillId);
  }

  List<Polyline> drawEdges() {
    return edges.map((e) {
      final hill1 = findHillEntry(e.hill1);
      final hill2 = findHillEntry(e.hill2);
      return Polyline(
        points: [
          LatLng(hill1.latitude, hill1.longitude),
          LatLng(hill2.latitude, hill2.longitude),
        ],
        strokeWidth: 1,
        color: const Color.fromARGB(255, 0, 0, 0),
      );
    }).toList();
  }

  @override
  initState() {
    super.initState();
    getAllHills();
    getFlaggedHills();
    getAllEdges();
    updatePosition();
  }
}