import "package:flutter/material.dart";


import "package:flutter_map/flutter_map.dart";
import "package:flutter_map/plugin_api.dart";
import "package:hribolazci/globals.dart";
import "package:hribolazci/scores.dart";
import "package:latlong2/latlong.dart";
import "package:geolocator/geolocator.dart";

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  final String title = "Hribolazci";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double lat = 46.056946;
  double long = 14.505751;

  var _mapController = MapController();

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
    _mapController.move(LatLng(lat, long), 10.0);
  }

  @override
  initState() {
    super.initState();
    updatePosition();
  }
}