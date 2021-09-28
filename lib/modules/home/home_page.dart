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
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: _toDoList.length,
                itemBuilder: (context, index) {
                  var item = _toDoList[index];

                  return CheckboxListTile(
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
                  );
                }),
          )
        ],
      ),
    );
  }
}
