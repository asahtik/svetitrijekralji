import "dart:convert";

import "package:jwt_decoder/jwt_decoder.dart";
import "package:http/http.dart" as http;

import "globals.dart";

class AuthStore {
  String token = "";
  bool initialised = false;

  Future<void> init() async {
    if (!initialised) {
      initialised = true;
      token = await secureStorage.read(key: "jwt") ?? "";
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
    // TODO
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE2ODAzNTk2ODEsImV4cCI6MTcxMTg5NTY4MSwiYXVkIjoid3d3LmV4YW1wbGUuY29tIiwic3ViIjoianJvY2tldEBleGFtcGxlLmNvbSIsIkdpdmVuTmFtZSI6IkpvaG5ueSIsIlN1cm5hbWUiOiJSb2NrZXQiLCJFbWFpbCI6Impyb2NrZXRAZXhhbXBsZS5jb20iLCJSb2xlIjpbIk1hbmFnZXIiLCJQcm9qZWN0IEFkbWluaXN0cmF0b3IiXX0.7d5KUazjINWz4sNv3DtvVxUkSl0THpk-FOw0CcJI7O0";
    await secureStorage.write(key: "jwt", value: token);
    return null;
    // final response = await http.post(getUri("/login"), body: <String, dynamic>{
    //   "email": email,
    //   "password": password,
    // }, headers: <String, String>{
    //   "Content-Type": "application/json",
    // });
    // if (response.statusCode == 200) {
    //   String newToken = jsonDecode(response.body)["token"];
    //   if (token.isNotEmpty) {
    //     token = newToken;
    //     await secureStorage.write(key: "jwt", value: token);
    //     return null;
    //   } else {
    //     return "Could not log in";
    //   }
    // } else if (response.statusCode == 400 || response.statusCode == 401) {
    //   return "Invalid email or password";
    // } else {
    //   return "An error occurred";
    // }
  }

  Future<String?> register(username, email, password, name) async {
    final response = await http.post(getUri("/register"), body: <String, dynamic>{
      "username": username,
      "email": email,
      "emailVisibility": true,
      "password": password,
      "passwordConfirm": password,
      "name": name,
    }, headers: <String, String>{
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