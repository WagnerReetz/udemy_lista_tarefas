import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

ControllerDataJson instance;

ControllerDataJson getInstanceDataJson(String nameFile) {
  if (instance == null) {
    instance = ControllerDataJson(nameFile);
  }

  return instance;
}

class ControllerDataJson {
  List _toDoList = [];

  String _nameFile = '';

  ControllerDataJson(this._nameFile);

  Future<File> saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/$_nameFile.json");
  }

  Future<String> readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<List> readDataAndDecodeJson() async {
    try {
      readData().then((value) {
        _toDoList = json.decode(value);
        return _toDoList;
      });
    } catch (e) {
      return null;
    }
  }

  List get toDoList => _toDoList;

  List getSubList(int index, String key, List lista) {
    List ret = lista[index][key];

    print(ret);

    if (ret == null) {
      ret = List();
    }

    return ret;
  }
}
