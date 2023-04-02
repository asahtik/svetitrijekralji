import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "config.dart";
import "auth.dart";

const String emailRegex = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
const int maxDistance = 100;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const secureStorage = FlutterSecureStorage();
final authStore = AuthStore();

Uri getUri(String path) {
  return apiSecure ? Uri.https(api, path) : Uri.http(api, "api/$path");
}

class UserEntry {
  late String id;
  late String username;
  late String groupId;
  late double points;

  UserEntry.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    username = json["username"];
    groupId = json["group"];
    points = json["points"].toDouble();
  }

  toJson() {
    return {
      "id": id,
      "username": username,
      "group": groupId,
      "points": points,
    };
  }
}

class HillEntry {
  late String id;
  late String name;
  late int height;
  late double latitude;
  late double longitude;

  HillEntry.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    height = json["height"];
    latitude = json["latitude"];
    longitude = json["longitude"];
  }
}

class AscentEntry {
  late String id;
  late String userId;
  late String hillId;
  late DateTime created;

  AscentEntry.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    userId = json["user"];
    hillId = json["hill"];
    created = DateTime.parse(json["created"]);
  }
}

class EdgeEntry {
  late String hill1;
  late String hill2;

  EdgeEntry.fromJson(Map<String, dynamic> json) {
    hill1 = json["hill1"];
    hill2 = json["hill2"];
  }
}