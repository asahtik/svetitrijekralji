import "dart:convert";

import "package:jwt_decoder/jwt_decoder.dart";
import "package:http/http.dart" as http;

import "globals.dart";

class AuthStore {
  String token = "";
  UserEntry? user;
  bool initialised = false;

  Future<void> init() async {
    if (!initialised) {
      initialised = true;
      final userEnc = await secureStorage.read(key: "user");
      if (userEnc != null) {
        token = await secureStorage.read(key: "jwt") ?? "";
        user = UserEntry.fromJson(jsonDecode(userEnc));
      }
    }
  }

  bool jwtValid() {
    if (token.isEmpty || JwtDecoder.tryDecode(token) == null) {
      return false;
    } else {
      return !JwtDecoder.isExpired(token);
    }
  }

  Future<String?> logIn(email, password) async {
    final response = await http.post(getUri("login"), body: jsonEncode(<String, dynamic>{
      "identity": email,
      "password": password,
    }), headers: <String, String>{
      "Content-Type": "application/json",
    });
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      String newToken = decoded["token"];
      if (newToken.isNotEmpty) {
        token = newToken;
        user = UserEntry.fromJson(decoded["record"]);
        await secureStorage.write(key: "jwt", value: token);
        await secureStorage.write(key: "user", value: jsonEncode(user!.toJson()));
        return null;
      } else {
        return "Could not log in";
      }
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      return "Invalid email or password";
    } else {
      return "An error occurred";
    }
  }

  Future<String?> register(username, email, password, name) async {
    final response = await http.post(getUri("register"), body: jsonEncode(<String, dynamic>{
      "username": username,
      "email": email,
      "emailVisibility": true,
      "password": password,
      "passwordConfirm": password,
      "name": name,
    }), headers: <String, String>{
      "Content-Type": "application/json",
    });
    if (response.statusCode == 200) {
      return null;
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      return "Username or email already in use";
    } else {
      return "An error occurred";
    }
  }
}