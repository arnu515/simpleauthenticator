import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';

class Application {
  String id;
  String name;
  String key;
  late String code;

  Application(this.id, this.name, this.key) {
    refreshCode();
  }

  String refreshCode() {
    String code = OTP.generateTOTPCodeString(key, DateTime.now().millisecondsSinceEpoch, isGoogle: true, algorithm: Algorithm.SHA1);
    this.code = code;
    return code;
  }

  void delete(Function callback) {
    print("Deleted $name");
    callback();
  }

  Widget display(BuildContext context, {void Function(String)? onDelete}) {
    deleteConfirmation() {
      deleteApp() {
        if (onDelete != null) onDelete(id);
        Navigator.of(context).pop();
      }

      AlertDialog alert = AlertDialog(
        title: const Text("Are you sure?"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(onPressed: deleteApp, child: const Text("Delete", style: TextStyle(color: Colors.red)))
        ]
      );

      showDialog(context: context, builder: (BuildContext context) => alert);
    }

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code)).then((_){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code $code copied to the clipboard')));
        });
      },
      onLongPress: deleteConfirmation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: "Ubuntu",
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0
                    )
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontFamily: "Ubuntu",
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        color: Colors.indigo
                      )
                    ),
                  ],
                )
              )
            ],
          )
        )
      )
    );
  }

  static List<Application> fetchAll() {
    return [
      Application("1", "name", "JBSWY3DPEHPK3PXP"),
      Application("2", "name1", "JBSWY3DPEHPK3PXP"),
      Application("3", "name2", "JBSWY3DPEHPK3PXP"),
    ];
  }
}
