import "package:flutter/material.dart";
import 'package:simpleauthenticator/models/application.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Application> apps = Application.fetchAll();
  
  _deleteApp(String id) {
    setState(() {
      apps.removeWhere((app) => app.id == id);
      apps = apps;
    });
  }

  @override
  Widget build(BuildContext context) {
    const padding = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple authenticator"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(padding, padding / 2, padding, padding / 2),
            child: Text("Tap to copy, long-press to delete", style: TextStyle(color: Colors.black54))
          ),
          apps.isNotEmpty ? Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(padding, padding, padding, padding),
              children: apps.map((app) => app.display(context, onDelete: _deleteApp)).toList(),
            )
          ) : const Padding(
            padding: EdgeInsets.all(padding * 2),
            child: Text("You haven't added any applications.", style: TextStyle(fontSize: 18.0))
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {  },
        tooltip: "Add application",
      ),
    );
  }
}
