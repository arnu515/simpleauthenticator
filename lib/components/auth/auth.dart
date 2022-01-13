import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  final Function(String)? onLogin;

  const Auth({Key? key, this.onLogin}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Auth();
}

class _Auth extends State<Auth> {
  final GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cpasswordController = TextEditingController();
  static const baseUrl = String.fromEnvironment("API_URL", defaultValue: "http://localhost:5000") + "/auth";
  String authType = "login";
  String formError = "";

  Future<void> _handle() async {
    setState(() {
      formError = "";
    });

    String email = emailController.text;
    String password = passwordController.text;
    String cpassword = cpasswordController.text;

    var body = {"email": email, "password": password};
    if (authType == "register") body["confirmPassword"] = cpassword;
    print(body);

    var res = await http.post(Uri.parse('$baseUrl/$authType'), body: json.encode(body), headers: {"Content-Type": "application/json"});
    print(res.body);

    var data = json.decode(res.body);
    if (!res.statusCode.toString().startsWith("2") || !data["ok"]) {
      setState(() {
        formError = data["message"];
      });
      return;
    }

    if (authType == "login") {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["data"]["token"]);
      if (widget.onLogin != null) widget.onLogin!(data["data"]["token"]);
      Navigator.of(context).pop();
    } else {
      cpasswordController.clear();
      passwordController.clear();
      setState(() {
        authType = "login";
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully registered, please log in")));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(authType == "login" ? "Login" : "Create account"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(12.0)),
            Text(authType == "login" ? "Login" : "Create account", style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            const Padding(padding: EdgeInsets.all(8.0)),
            Text("${authType == "login" ? "Login" : "Create an account"} to save your applications to the cloud. All your data will be encrypted in such a way that only you can access them.", style: const TextStyle(fontSize: 16.0)),
            const Padding(padding: EdgeInsets.all(8.0)),
            Form(
              key: _authFormKey,
              child: Column(
                children: [
                  const Text("Email", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: "Enter your email"),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) return "Enter a value";
                      return null;
                    }
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  const Text("Password", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                  TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(hintText: "Enter your password"),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) return "Enter a value";
                      return null;
                    }
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  if (authType != "login") const Text("Confirm password", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                  if (authType != "login") TextFormField(
                      obscureText: true,
                      controller: cpasswordController,
                      decoration: const InputDecoration(hintText: "Re-enter that password"),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) return "Enter a value";
                        if (passwordController.text != value) return "Passwords don't match";
                        return null;
                      }
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  if (formError.isNotEmpty) Text(formError, style: const TextStyle(color: Colors.red, fontSize: 18.0)),
                  if (formError.isNotEmpty) const Padding(padding: EdgeInsets.all(8.0)),
                  Wrap(
                    children: [
                      ElevatedButton(
                        onPressed: _handle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(authType == "login" ? "Login" : "Create account", style: const TextStyle(fontSize: 18.0))
                        )
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0)),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            authType = authType == "login" ? "register" : "login";
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(authType == "login" ? "Create account" : "Login instead", style: const TextStyle(fontSize: 18.0, color: Colors.indigo))
                        ),
                        style: ElevatedButton.styleFrom(primary: Colors.white)
                      )
                    ],
                  )
                ]
              )
            )
          ],
        )
      )
    );
  }
}
