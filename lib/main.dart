import 'package:flutter/material.dart';
import 'components/home/home.dart';

void main() {
  runApp(const SimpleAuthenticator());
}

class SimpleAuthenticator extends StatelessWidget {
  const SimpleAuthenticator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Simple Authenticator",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: "Ubuntu",
      ),
      home: const Home()
    );
  }
}
