import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lista_tarefas/data_json.dart';
import 'package:lista_tarefas/second_route.dart';

class FirstRoute extends StatefulWidget {
  @override
  _FirstRouteState createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
  final _edControler = TextEditingController();
  final _controllerDataJson = getInstanceDataJson('data');

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    setState(() {
      _controllerDataJson.readDataAndDecodeJson();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(microseconds: 500));

    setState(() {
      _controllerDataJson.toDoList.sort((a, b) {
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
        newTodo["key"] = Random.secure().nextInt(4294967296);

        _edControler.text = '';
        _controllerDataJson.toDoList.add(newTodo);
        _controllerDataJson.saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Listas'),
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
                          labelText: "Nova Lista",
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
                  itemCount: _controllerDataJson.toDoList.length,
                  itemBuilder: _buildItem),
            ),
          )
        ],
      ),

      // body: Center(
      //   child: ElevatedButton(
      //     child: Text('Open route'),
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => SecondRoute()),
      //       );
      //     },
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
            _lastRemoved = Map.from(_controllerDataJson.toDoList[index]);
            _lastRemovedPos = index;
            _controllerDataJson.toDoList.removeAt(index);
            _controllerDataJson.saveData();

            final snack = SnackBar(
                content: Text("Lista \"${_lastRemoved["title"]}\" removida!"),
                action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() {
                      _controllerDataJson.toDoList
                          .insert(_lastRemovedPos, _lastRemoved);
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
        child: _buildLine(index));
  }

  Widget _buildLine(int index) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage("images/list.png")),
      title: Text(_controllerDataJson.toDoList[index]["title"]),
      subtitle: Text('A strong animal'),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SecondRoute(index)),
        );
      },
      selected: true,
    );

    // return CheckboxListTile(
    //   onChanged: (check) {
    //     setState(() {
    //       _toDoList[index]["ok"] = check;
    //       _saveData();
    //     });
    //   },
    //   title: Text(_toDoList[index]["title"]),
    //   value: _toDoList[index]["ok"],
    //   secondary: CircleAvatar(
    //     child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
    //   ),
    // );
  }
}
