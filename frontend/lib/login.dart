import "package:flutter/material.dart";
import "package:hribolazci/main.dart";

import "globals.dart";
import "register.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String errorText = "";
  var emailCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();

  updateErrorText(String text) {
    setState(() {
      errorText = text;
    });
  }

  _logIn() async {
    updateErrorText("");
    if (_formKey.currentState?.validate() ?? false) {
      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text;
      final error = await authStore.logIn(email, password);
      if (error != null) {
        updateErrorText(error);
      } else {
        navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const MainPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var title = const Text(
      "Login Page",
      style: TextStyle(fontSize: 30),
    );
    var email = TextFormField(
      controller: emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: "Enter your email",
      ),
      autofocus: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Email cannot be empty";
        } else if (!RegExp(emailRegex).hasMatch(value)) {
          return "Email must be valid";
        }
        return null;
      },
    );
    var password = TextFormField(
      controller: passwordCtrl,
      keyboardType: TextInputType.visiblePassword,
      decoration: const InputDecoration(
        hintText: "Enter your password",
      ),
      autofocus: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password cannot be empty";
        }
        if (value.length < 8) {
          return "Password must be at least 8 characters";
        }
        return null;
      },
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) {
        _logIn();
      },
    );
    var errorTextObj = Text(
      errorText,
      style: const TextStyle(color: Colors.red),
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                title,
                const SizedBox(height: 20),
                email,
                password,
                const SizedBox(height: 10),
                errorText.isNotEmpty ? errorTextObj : const SizedBox.shrink(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    _logIn();
                  },
                  child: const Text("Login"),
                ),
                const SizedBox(height: 2),
                TextButton(
                  onPressed: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text("Register")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}