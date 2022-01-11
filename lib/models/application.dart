import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Application {
  String name;
  String payload;
  late String code;

  Application(this.name, this.payload) {
    code = "123456";
  }

  void delete(Function callback) {
    print("Deleted $name");
    callback();
  }

  Widget display(BuildContext context) {
    deleteConfirmation() {
      AlertDialog alert = AlertDialog(
        title: const Text("Are you sure?"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(onPressed: () => delete(() => Navigator.of(context).pop()), child: const Text("Delete", style: TextStyle(color: Colors.red)))
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
                  ),
                  Text(
                    payload,
                    style: const TextStyle(
                      fontFamily: "Ubuntu",
                      fontWeight: FontWeight.w300,
                      fontSize: 16.0,
                      color: Colors.black87
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
      Application("name", "payload"),
      Application("name1", "payload1"),
      Application("name2", "payload2"),
    ];
  }
}
