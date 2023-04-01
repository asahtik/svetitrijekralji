import "package:flutter/material.dart";
import "package:hribolazci/login.dart";

import "globals.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String errorText = "";
  var usernameCtrl = TextEditingController();
  var nameCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  var confirmPasswordCtrl = TextEditingController();

  updateErrorText(String text) {
    setState(() {
      errorText = text;
    });
  }

  _register() async {
    updateErrorText("");
    if (_formKey.currentState?.validate() ?? false) {
      final username = usernameCtrl.text;
      final name = nameCtrl.text;
      final email = emailCtrl.text;
      final password = confirmPasswordCtrl.text;

      final error = await authStore.register(username, email, password, name);
      if (error != null) {
        updateErrorText(error);
      } else {
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState?.pop();
        } else {
          navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var title = const Text(
      "Register",
      style: TextStyle(fontSize: 30),
    );
    var username = TextFormField(
      controller: usernameCtrl,
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        hintText: "Enter your username",
      ),
      autofocus: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Username cannot be empty";
        }
        return null;
      },
    );
    var name = TextFormField(
      controller: nameCtrl,
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        hintText: "Enter your name",
      ),
      autofocus: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Name cannot be empty";
        }
        return null;
      },
    );
    var email = TextFormField(
      controller: emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: "Enter your email",
      ),
      autofocus: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
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
      autofocus: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password cannot be empty";
        }
        if (value.length < 8) {
          return "Password must be at least 8 characters";
        }
        return null;
      },
    );
    var confirmPassword = TextFormField(
      controller: confirmPasswordCtrl,
      keyboardType: TextInputType.visiblePassword,
      decoration: const InputDecoration(
        hintText: "Confirm your password",
      ),
      autofocus: false,
      validator: (value) {
        if (value != passwordCtrl.text) {
          return "Passwords do not match";
        }
        return null;
      },
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) {
        _register();
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
                username,
                name,
                email,
                password,
                confirmPassword,
                const SizedBox(height: 10),
                errorText.isNotEmpty ? errorTextObj : const SizedBox.shrink(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    _register();
                  },
                  child: const Text("Register"),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    navigatorKey.currentState?.pop();
                  },
                  child: const Text("Log in")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}