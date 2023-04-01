import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "config.dart";
import "auth.dart";

const String emailRegex = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const secureStorage = FlutterSecureStorage();
final authStore = AuthStore();

Uri getUri(String path) {
  return apiSecure ? Uri.https(api, path) : Uri.http(api, path);
}