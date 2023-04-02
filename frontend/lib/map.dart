import "dart:async";

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

  String position = "?";
  String points = "?";

  bool showAllHills = true;
  HillEntry? nearbyHill;
  AscentEntry? nearbyAscent;
  bool nearbyHillValid = true;

  List<HillEntry> allHills = [];
  List<AscentEntry> allAscents = [];
  List<HillEntry> flaggedHills = [];
  List<EdgeEntry> edges = [];
  List<EdgeEntry> flaggedEdges = [];

  Map<String, Color> userColors = {};

  List<UserEntry> competitors = [];

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
                zoom: 12.0,
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
                PolylineLayer(
                  polylineCulling: true,
                  polylines: showAllHills ? drawEdges2() : [],
                ),
                PolylineLayer(
                  polylineCulling: true,
                  polylines: !showAllHills ? drawOwnedEdges() : [],
                ),
                CircleLayer(
                  circles: showAllHills ? drawCircles() : [],
                ),
                CircleLayer(
                  circles: !showAllHills ? flaggedHills.map((h) => CircleMarker(
                    point: LatLng(h.latitude, h.longitude),
                    radius: 1000,
                    borderStrokeWidth: 3,
                    borderColor: const Color.fromARGB(255, 0, 0, 255),
                    color: const Color.fromARGB(0, 0, 0, 0),
                    useRadiusInMeter: true,
                  )).toList() : [],
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      "#$position ($points points)",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Switch(value: showAllHills, onChanged: (value) {
                        setState(() {
                          showAllHills = value;
                        });
                      }),
                      IconButton(onPressed: () {
                        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => const ScoresPage()));
                      }, icon: const Icon(Icons.analytics_outlined, color: Colors.white,))
                    ],
                  ),
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
            if (nearbyHill != null && nearbyAscent != null) {
              if (nearbyHillValid) {
                flag(nearbyAscent!.id);
              }
            } else {
              getAllAscents();
              getCompetitors();
              getFlaggedHills();
              getAllEdges();
              updatePosition(true);
            }
          },
          tooltip: nearbyHill == null ? "Refresh" : (nearbyHillValid ? "Flag" : "Too soon"),
          child: Icon(nearbyHill == null ? Icons.refresh : (nearbyHillValid ? Icons.flag : Icons.access_time)),
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

  flag(String ascendId) async {
    await http.flagAscent(ascendId);

    getAllAscents();
    getCompetitors();
    getFlaggedHills();
    getAllEdges();
    updatePosition(true);
  }

  updatePosition(reposition) async {
    Position position = await _determinePosition();
    lat = position.latitude;
    long = position.longitude;
    nearbyHill = null;
    nearbyAscent = null;
    nearbyHillValid = true;
    getNearbyHill();
    if (reposition) {
      _mapController.move(LatLng(lat, long), _mapController.zoom);
    }
  }

  getNearbyHill() async {
    for (var hill in allHills) {
      final distance = Geolocator.distanceBetween(lat, long, hill.latitude, hill.longitude);
      if (distance < maxDistance) {
        if (allAscents.any((a) => a.hillId == hill.id && a.userId.isNotEmpty && (DateTime.now().difference(a.created)).inHours < 1)) {
          nearbyHillValid = false;
        } else {
          nearbyHillValid = true;
        }
        setState(() {
          nearbyAscent = allAscents.firstWhere((a) => a.hillId == hill.id);
          nearbyHill = hill;
        });
        break;
      }
    }
  }

  getAllHills() async {
    var response = await http.getAllHills();
    if (response != null) {
      setState(() {
        allHills = response;
      });
    }
  }

  getAllAscents() async {
    var response = await http.getAllAscents();
    if (response != null) {
      setState(() {
        allAscents = response;
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
    if (response != null) {
      setState(() {
        flaggedHills = response;
      });
    }
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
            points = c.points.toString();
            position = (i + 1).toString();
            break;
          }
        }
      });
    }
  }

  HillEntry? findHillEntry(String hillId, bool onlyFlagged) {
    final list = !onlyFlagged ? allHills : flaggedHills;
    for (var hill in list) {
      if (hill.id == hillId) {
        return hill;
      }
    }
    return null;
  }

  HillEntry? findHillEntryInList(String hillId, List<HillEntry> list) {
    for (var hill in list) {
      if (hill.id == hillId) {
        return hill;
      }
    }
    return null;
  }

  HillEntry? findHillEntry2(String hillId) {
    for (var hill in allHills) {
      if (hill.id == hillId) {
        return hill;
      }
    }
    return null;
  }

  List<CircleMarker> drawCircles() {
    List<CircleMarker> markers = [];
    final allUsers = allAscents.map((a) => a.userId).toSet().toList();
    final userHills = allUsers.map((u) {
      final ascents = allAscents.where((a) => a.userId == u).toList();
      final hills = ascents.map((a) => a.hillId).toSet().toList();
      return hills;
    }).toList();
    var incr = 360 / allUsers.length;
    for (var i = 0; i < allUsers.length; i++) {
      final hills = userHills[i];
      final color = allUsers[i].isEmpty ? const Color.fromARGB(255, 0, 0, 0) : HSVColor.fromAHSV(1, incr * i, 0.8, 0.7).toColor();
      for (var hillId in hills) {
        final hill = findHillEntry2(hillId);
        if (hill != null) {
          markers.add(CircleMarker(
            point: LatLng(hill.latitude, hill.longitude),
            radius: 1000,
            borderStrokeWidth: 3,
            borderColor: color,
            color: const Color.fromARGB(0, 0, 0, 0),
            useRadiusInMeter: true,
          ));
        }
      }
    }
    return markers;
  }

  List<Polyline> drawEdges2() {
    List<Polyline> markers = [];
    final allUsers = allAscents.map((a) => a.userId).toSet().toList();
    final userHills = allUsers.map((u) {
      final ascents = allAscents.where((a) => a.userId == u).toList();
      final hills = ascents.map((a) => a.hillId).toSet().toList();
      return hills;
    }).toList();
    var incr = 360 / allUsers.length;
    for (var i = 0; i < allUsers.length; i++) {
      final hills = allHills.where((h) => userHills[i].contains(h.id)).toList();
      final color = allUsers[i].isEmpty ? const Color.fromARGB(255, 0, 0, 0) : HSVColor.fromAHSV(1, incr * i, 0.8, 0.7).toColor();
      
      for (var e in edges) {
        final hill1 = findHillEntryInList(e.hill1, hills);
        final hill2 = findHillEntryInList(e.hill2, hills);
        if (hill1 != null && hill2 != null) {
          markers.add(Polyline(
            points: [
              LatLng(hill1.latitude, hill1.longitude),
              LatLng(hill2.latitude, hill2.longitude),
            ],
            strokeWidth: 1,
            color: color,
          ));
        }
      }
    }
    return markers;
  }

  List<Polyline> drawEdges() {
    return edges.map((e) {
      final hill1 = findHillEntry(e.hill1, false)!;
      final hill2 = findHillEntry(e.hill2, false)!;
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

  List<Polyline> drawOwnedEdges() {
    List<Polyline> list = [];
    for (var e in edges) {
      final hill1 = findHillEntry(e.hill1, true);
      final hill2 = findHillEntry(e.hill2, true);
      if (hill1 != null && hill2 != null) {
        list.add(Polyline(
          points: [
            LatLng(hill1.latitude, hill1.longitude),
            LatLng(hill2.latitude, hill2.longitude),
          ],
          strokeWidth: 1,
          color: const Color.fromARGB(255, 0, 0, 255),
        ));
      }
    }
    return list;
  }

  @override
  initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 10), (Timer t) {
      // Didn't have time for SSE
      getAllAscents();
      getCompetitors();
      getFlaggedHills();
      getAllEdges();
      updatePosition(false);
    });
    getAllAscents();
    getCompetitors();
    getAllHills();
    getFlaggedHills();
    getAllEdges();
    updatePosition(true);
  }
}