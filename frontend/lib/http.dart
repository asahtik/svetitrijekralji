import "dart:convert";

import "package:http/http.dart" as http;

import "globals.dart";

Future<List<HillEntry>?> getAllHills() async {
  final response = await http.get(getUri("hills"), headers: <String, String>{
    "Content-Type": "application/json",
    "Authorization": authStore.token
  });
  if (response.statusCode == 200) {
    final items = jsonDecode(response.body)["items"] as List;
    return items.map((h) => HillEntry.fromJson(h)).toList();
  } else {
    return null;
  }
}

Future<List<AscentEntry>?> getAllAscents() async {
  final response = await http.get(getUri("ascents/${authStore.user?.groupId ?? ''}"), headers: <String, String>{
    "Content-Type": "application/json",
    "Authorization": authStore.token
  });
  if (response.statusCode == 200) {
    final items = jsonDecode(response.body)["items"] as List;
    return items.map((h) => AscentEntry.fromJson(h)).toList();
  } else {
    return null;
  }
}

Future<List<HillEntry>?> getFlaggedHills() async {
  final response = await http.get(getUri("hills/${authStore.user?.id ?? ''}"), headers: <String, String>{
    "Content-Type": "application/json",
    "Authorization": authStore.token
  });
  if (response.statusCode == 200) {
    final items = jsonDecode(response.body)["items"] as List;
    return items.map((h) => HillEntry.fromJson(h["expand"]["hill"])).toList();
  } else {
    return null;
  }
}

Future<List<EdgeEntry>?> getAllEdges() async {
  final response = await http.get(getUri("edges/${authStore.user?.groupId ?? ''}"), headers: <String, String>{
    "Content-Type": "application/json",
    "Authorization": authStore.token
  });
  if (response.statusCode == 200) {
    final items = jsonDecode(response.body)["items"] as List;
    return items.map((h) => EdgeEntry.fromJson(h)).toList();
  } else {
    return null;
  }
}

Future<List<UserEntry>?> getUsersInGroup() async {
  final response = await http.get(getUri("users/${authStore.user?.groupId ?? ''}"), headers: <String, String>{
    "Content-Type": "application/json",
    "Authorization": authStore.token
  });
  if (response.statusCode == 200) {
    final items = jsonDecode(response.body)["items"] as List;
    return items.map((h) => UserEntry.fromJson(h)).toList();
  } else {
    return null;
  }
}

Future<void> flagAscent(String ascentId) async {
  await http.put(getUri("flag/$ascentId"), headers: <String, String> {
    "Authorization": authStore.token
  }, body: {
    "userId": authStore.user!.id
  });
}