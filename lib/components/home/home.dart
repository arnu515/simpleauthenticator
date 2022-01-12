import 'dart:async';

import "package:flutter/material.dart";
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:simpleauthenticator/models/application.dart';
import 'package:simpleauthenticator/util/storage.dart';
import 'package:simpleauthenticator/components/scanqr/scanqr.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Application> apps = [];
  final GlobalKey<FormState> _addAppFormKey = GlobalKey<FormState>();
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

  Widget createAddModal(BuildContext context) {
    void _gotQrCode(Barcode qrCode, BuildContext scanQrCodeWidgetContext) {
      print("Scanned: ${qrCode.code}");
      Navigator.of(scanQrCodeWidgetContext).pop();
    }

    String? enteredName, enteredKey;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: 350,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (!_addAppFormKey.currentState!.validate()) return;
                            _addAppFormKey.currentState!.save();
                            if (enteredKey == null || enteredName == null) return;
                            setState(() {
                              apps.add(Application(DateTime.now().millisecondsSinceEpoch.toString(), enteredName!, enteredKey!));
                              content["apps"] = apps.map((app) => app.toMap()).toList();
                              Storage.setContent(content);
                            });
                            Navigator.pop(context);
                          }, 
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0), 
                            child: Text("Add application", style: TextStyle(fontSize: 18.0))
                          )
                        ),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ScanQR(onQrCode: (q) => _gotQrCode(q, context))));
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("Scan QR Code", style: TextStyle(fontSize: 18.0, color: Colors.indigo))
                          ),
                          style: ElevatedButton.styleFrom(primary: Colors.white)
                        )
                      ],
                    )
                  ]
                )
              )
            ]
          )
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
          showModalBottomSheet(context: context, builder: createAddModal, isScrollControlled: true);
        },
        tooltip: "Add application",
      ),
    );
  }
}
