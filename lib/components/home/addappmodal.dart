import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:simpleauthenticator/components/scanqr/scanqr.dart';
import 'package:simpleauthenticator/models/application.dart';

class AddAppModal extends StatefulWidget {
  final Function(Application)? onAppAdded;

  const AddAppModal({Key? key, this.onAppAdded}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddAppModalState();
}

class _AddAppModalState extends State<AddAppModal> {
  final GlobalKey<FormState> _addAppFormKey = GlobalKey<FormState>();
  final enteredNameController = TextEditingController();
  final enteredKeyController = TextEditingController();
  String qrCodeError = "";

  @override
  Widget build(BuildContext context) {
    void _gotQrCode(Barcode qrCode, BuildContext scanQrCodeWidgetContext) {
      print(qrCode.code);
      var uri = Uri.tryParse(qrCode.code);
      if (!(uri?.isAbsolute ?? false)) {
        setState(() => qrCodeError = "Invalid QR Code. This QR Code is not a URL");
        return;
      }
      if (!uri!.scheme.startsWith("otpauth")) {
        setState(() => qrCodeError = 'Invalid QR Code. URL Scheme should be with "otpauth". This QR Code\'s scheme is ${uri.scheme}');
        return;
      }
      var appName = uri.path.replaceFirst("/", "");
      var key = uri.queryParameters["secret"] ?? uri.queryParameters["key"];
      if (key == null || key.isEmpty) {
        setState(() => qrCodeError = 'Invalid QR Code. Key was not found in query string');
        return;
      }
      setState(() => qrCodeError = '');
      enteredNameController.text = appName;
      enteredKeyController.text = key;
    }

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
                      controller: enteredNameController,
                      decoration: const InputDecoration(hintText: "Enter the application's name"),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) return "Enter a value";
                        return null;
                      }
                    ),
                    const Padding(padding: EdgeInsets.all(4.0)),
                    const Text("App key", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                    TextFormField(
                      controller: enteredKeyController,
                      decoration: const InputDecoration(hintText: "Enter TOTP Key"),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) return "Enter a value";
                        return null;
                      }
                    ),
                    const Padding(padding: EdgeInsets.all(4.0)),
                    Wrap(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (!_addAppFormKey.currentState!.validate()) return;
                            var enteredName = enteredNameController.text;
                            var enteredKey = enteredKeyController.text;
                            if (enteredKey.isEmpty || enteredName.isEmpty) return;
                            if (widget.onAppAdded != null) widget.onAppAdded!(Application(DateTime.now().millisecondsSinceEpoch.toString(), enteredName, enteredKey));
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("Add application", style: TextStyle(fontSize: 18.0))
                          )
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0)),
                        if (Platform.isAndroid || Platform.isIOS) ElevatedButton(
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
                    ),
                    const Padding(padding: EdgeInsets.all(4.0)),
                    qrCodeError.isNotEmpty ? Text(qrCodeError, style: const TextStyle(color: Colors.red, fontSize: 16.0)) : const Text("")
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }
}
