// TODO: Encrypt this data before storing.

import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef _FileContentType = Map<String, dynamic>;

class Storage {
  static const String fileName = "simpleauthenticator-storage.json";
  static const _FileContentType initData = {"apps": []};
  
  static Future<File> createFile({force = false}) async {
    var dir = await Storage.getDirectory();
    print("[createFile()] Creating file ${Storage.fileName} in ${dir.path}");
    var file = File('${dir.path}/${Storage.fileName}');
    if (force || !file.existsSync()) {
      await file.create();
      await file.writeAsString(json.encode(initData));
    }
    return file;
  }
  
  static Future<Directory> getDirectory() {
    return getApplicationDocumentsDirectory();
  }
  
  static Future<File> getFile() async {
    var dir = await Storage.getDirectory();
    print("[getFile()] Getting file ${Storage.fileName} in ${dir.path}");
    var file = File('${dir.path}/${Storage.fileName}');
    if (file.existsSync()) {
      return file;
    } else {
      file = await createFile(force: true);
      return file;
    }
  }

  static Future<_FileContentType> getContent() async {
    var file = await getFile();
    print("[getContent()] Getting content of ${file.path}");
    try {
      var content = json.decode(await file.readAsString());
      print("[getContent() 2] Got content:");
      print(content);
      return content;
    } catch (e) {
      if (e is FileSystemException || e is FormatException) {
        await createFile(force: true);
        return await getContent();
      } else {
        rethrow;
      }
    }
  }

  static Future<void> setContent(_FileContentType content) async {
    var file = await getFile();
    print("[setContent()] Setting content of ${file.path}");
    try {
      await file.writeAsString(json.encode(content));
      print("[setContent() 2] Set content");
    } catch (e) {
      if (e is FileSystemException || e is FormatException) {
        await createFile(force: true);
        await setContent(content);
      } else {
        rethrow;
      }
    }
  }
}

class CloudStorage {
  static const baseUrl = String.fromEnvironment("API_URL", defaultValue: "http://localhost:5000") + "/store";

  static Future<void> setJson(String token) async {
    var content = await Storage.getContent();
    var res = await http.post(Uri.parse(baseUrl), body: json.encode(content), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    });
    var data = json.decode(res.body);
    print(data);
  }

  static Future<_FileContentType?> getJson(String token) async {
    var res = await http.get(Uri.parse(baseUrl), headers: {"Authorization": "Bearer $token"});
    var data = json.decode(res.body);
    print(data);
    if (res.statusCode == 404) return null;
    return data["data"];
  }
}
