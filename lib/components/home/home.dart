import 'dart:async';

import "package:flutter/material.dart";
import 'package:simpleauthenticator/components/home/addappmodal.dart';
import 'package:simpleauthenticator/models/application.dart';
import 'package:simpleauthenticator/util/storage.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Application> apps = [];
  Timer? updateCodeTimer;
  Map<String, dynamic> content = Storage.initData;

  refreshCodes(Timer timer) {
    for (var app in apps) {app.refreshCode();}
    setState(() {
      apps = apps;
    });
  }

  _loadAppsFromStorage() async {
    var content = await Storage.getContent();
    print("[home.dart 1] loaded content");
    print(content);

    print("[home.dart 2] setting apps");
    if (content["apps"] is! List) {
      content["apps"] = [];
      await Storage.setContent(content);
    }
    var appsList = (content["apps"] as List<dynamic>);
    List<Application> apps = [];
    for (int i = 0; i < appsList.length; i++) {
      if (appsList[i] is! Map<String, dynamic>) {
        appsList.removeAt(i);
        content["apps"] = appsList;
        await Storage.setContent(content);
      } else {
        Map<String, dynamic> app = appsList[i];
        String? id = app["id"];
        String? name = app["name"];
        String? key = app["key"];
        if (id == null || name == null || key == null) {
          appsList.removeAt(i);
          content["apps"] = appsList;
          await Storage.setContent(content);
        } else {
          print("[home.dart 3] adding application: Application(id: $id, name: $name, key: $key)");
          var application = Application(id, name, key);
          apps.add(application);
        }
      }
    }
    setState(() {
      this.apps = apps;
      this.content = content;
    });
  }

  @override
  initState() {
    super.initState();
    updateCodeTimer = Timer.periodic(const Duration(seconds: 5), refreshCodes);
    _loadAppsFromStorage();
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
      content["apps"] = apps.map((app) => app.toMap()).toList();
      Storage.setContent(content);
    });
  }

  _addApp(Application app) {
    setState(() {
      apps.add(app);
      apps = apps;
      content["apps"] = apps.map((app) => app.toMap()).toList();
      Storage.setContent(content);
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
            child: Text("You haven't added any applications.", style: TextStyle(fontSize: 20.0))
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () { 
          showModalBottomSheet(context: context, builder: (BuildContext context) => AddAppModal(onAppAdded: _addApp), isScrollControlled: true);
        },
        tooltip: "Add application",
      ),
    );
  }
}
