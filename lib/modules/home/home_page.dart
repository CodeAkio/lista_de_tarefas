import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _todoController = TextEditingController();

  List _toDoList = [];
  Map<String, dynamic>? _lastRemoved;
  int? _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    print("Iniciou");

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data!);
        print("Leu iniciar");
      });
    });
  }

  void _addTask() {
    Map<String, dynamic> newTask = {};
    newTask["title"] = _todoController.text;
    newTask["ok"] = false;

    setState(() {
      _toDoList.add(newTask);
    });

    _todoController.text = "";

    _saveData();
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    var file = File("${directory.path}/data.json");

    return file;
  }

  Future<File> _saveData() async {
    var data = json.encode(_toDoList);
    final file = await _getFile();
    var updatedFile = file.writeAsString(data);
    print("salvou");

    return updatedFile;
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      print(file.readAsString());
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _toDoList.sort((elem1, elem2) {
        if (elem1["ok"] && !elem2["ok"]) {
          return 1;
        } else if (!elem1["ok"] && elem2["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });
    });

    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                FloatingActionButton(
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.blueAccent,
                  onPressed: _addTask,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    var item = _toDoList[index];

    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: CheckboxListTile(
        title: Text(item["title"]),
        value: item["ok"],
        secondary: CircleAvatar(
          child: Icon(item["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (value) {
          setState(() {
            item["ok"] = value;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        _lastRemoved = Map.from(item);
        _lastRemovedPos = index;

        setState(() {
          _toDoList.removeAt(index);
        });

        _saveData();

        final snack = SnackBar(
          content: Text("Tarefa \"${_lastRemoved!["title"]}\" removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _toDoList.insert(_lastRemovedPos!, _lastRemoved);
              });

              _saveData();
            },
          ),
          duration: const Duration(seconds: 2),
        );

        ScaffoldMessenger.of(context).showSnackBar(snack);
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }
}
