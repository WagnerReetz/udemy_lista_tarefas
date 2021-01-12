import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lista_tarefas/data_json.dart';

class SecondRoute extends StatefulWidget {
  final int _indexFather;

  @override
  _SecondRouteState createState() => _SecondRouteState(_indexFather);

  SecondRoute(this._indexFather);
}

class _SecondRouteState extends State<SecondRoute> {
  final _edControler = TextEditingController();
  final _controllerDataJson = getInstanceDataJson('data');

  int _indexFather;
  List _toDoListSec = [];

  _SecondRouteState(this._indexFather);

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    setState(() {
      _toDoListSec = _controllerDataJson.getSubList(
          _indexFather, 'itens', _controllerDataJson.toDoList);
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(microseconds: 500));

    setState(() {
      _toDoListSec.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _controllerDataJson.saveData();
    });

    return null;
  }

  void _addToDo() {
    Map<String, dynamic> newTodo = Map();

    if (_edControler.text.isNotEmpty) {
      setState(() {
        newTodo["title"] = _edControler.text;
        newTodo["ok"] = false;
        _edControler.text = '';
        _toDoListSec.add(newTodo);
        _controllerDataJson.toDoList[_indexFather]['itens'] = _toDoListSec;
        _controllerDataJson.saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                      controller: _edControler,
                      decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(color: Colors.blueAccent))),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoListSec.length,
                  itemBuilder: _buildItem),
            ),
          )
        ],
      ),

      // body: Center(
      //   child: ElevatedButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: Text('Go back!'),
      //   ),
      // ),
    );
  }

  Widget _buildItem(context, index) {
    return Dismissible(
        background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment(-0.9, 0.0),
              child: Icon(Icons.delete, color: Colors.white),
            )),
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_toDoListSec[index]);
            _lastRemovedPos = index;
            _toDoListSec.removeAt(index);
            _controllerDataJson.toDoList[_indexFather]['itens'] = _toDoListSec;
            _controllerDataJson.saveData();

            final snack = SnackBar(
                content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
                action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() {
                      _toDoListSec.insert(_lastRemovedPos, _lastRemoved);
                      _controllerDataJson.toDoList[_indexFather]['itens'] =
                          _toDoListSec;
                      _controllerDataJson.saveData();
                    });
                  },
                ),
                duration: Duration(seconds: 2));

            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(snack);
          });
        },
        direction: DismissDirection.startToEnd,
        key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
        child: CheckboxListTile(
          onChanged: (check) {
            setState(() {
              _toDoListSec[index]["ok"] = check;
              _controllerDataJson.toDoList[_indexFather]['itens'] =
                  _toDoListSec;
              _controllerDataJson.saveData();
            });
          },
          title: Text(_toDoListSec[index]["title"]),
          value: _toDoListSec[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(_toDoListSec[index]["ok"] ? Icons.check : Icons.error),
          ),
        ));
  }
}
