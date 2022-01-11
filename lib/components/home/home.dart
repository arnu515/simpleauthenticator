import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:simpleauthenticator/models/application.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Application> apps = Application.fetchAll();
  final GlobalKey<FormState> _addAppFormKey = GlobalKey<FormState>();
  Timer? updateCodeTimer;

  refreshCodes(Timer timer) {
    for (var app in apps) {app.refreshCode();}
    setState(() {
      apps = apps;
    });
  }

  @override
  initState() {
    super.initState();
    updateCodeTimer = Timer.periodic(const Duration(seconds: 5), refreshCodes);
  }

  @override
  deactivate() {
    if (updateCodeTimer != null) updateCodeTimer!.cancel();
    super.deactivate();
  }
  
  _deleteApp(String id) {
    setState(() {
      apps.removeWhere((app) => app.id == id);
      apps = apps;
    });
  }

  Widget createAddModal(BuildContext context) {
    String? enteredName, enteredKey;

    return SizedBox(
      height: 350,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add application", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Form(
              key: _addAppFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(12.0)),
                  const Text("Name", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                  const Padding(padding: EdgeInsets.all(2.0)),
                  TextFormField(
                    onSaved: (String? value) => enteredName = value,
                    decoration: const InputDecoration(hintText: "Enter the application's name"),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) return "Enter a value";
                      return null;
                    }
                  ),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  const Text("App key", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                  TextFormField(
                    onSaved: (String? value) => enteredKey = value,
                    decoration: const InputDecoration(hintText: "Enter TOTP Key"),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) return "Enter a value";
                      return null;
                    }
                  ),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  ElevatedButton(onPressed: () {
                    if (!_addAppFormKey.currentState!.validate()) return;
                    _addAppFormKey.currentState!.save();
                    if (enteredKey == null || enteredName == null) return;
                    setState(() {
                      apps.add(Application(DateTime.now().millisecondsSinceEpoch.toString(), enteredName!, enteredKey!));
                    });
                    Navigator.pop(context);
                  }, child: const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text("Add application", style: TextStyle(fontSize: 18.0))))
                ]
              )
            )
          ]
        )
      )
    );
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
            child: Text("You haven't added any applications.", style: TextStyle(fontSize: 20.0))
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () { 
          showModalBottomSheet(context: context, builder: createAddModal);
        },
        tooltip: "Add application",
      ),
    );
  }
}
