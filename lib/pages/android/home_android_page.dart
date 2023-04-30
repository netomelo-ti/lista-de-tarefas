import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomeAndroidPage extends StatefulWidget {
  const HomeAndroidPage({super.key});

  @override
  State<HomeAndroidPage> createState() => _HomeAndroidPageState();
}

class _HomeAndroidPageState extends State<HomeAndroidPage> {
  final _fieldController = TextEditingController();
  List tarefas = [];
  late Map<String, dynamic> tarefaRemovida;
  late int indexTarefaRemovida;

  @override
  void initState() {
    super.initState();

    lerTarefas().then((data) {
      setState(() {
        tarefas = json.decode(data);
      });
    });
  }

  void adicionarTarefa() {
    if (_fieldController.text.trim() == "") return;

    Map<String, dynamic> novaTarefa = Map();
    novaTarefa['title'] = _fieldController.text.trim();
    novaTarefa['check'] = false;
    _fieldController.text = '';

    setState(() {
      tarefas.add(novaTarefa);
      salvarTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Lista de Tarefas"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fieldController,
                      decoration:
                          const InputDecoration(labelText: "Nova Tarefa"),
                    ),
                  ),
                  ElevatedButton.icon(
                    label: const Text("Adicionar"),
                    icon: const Icon(Icons.add),
                    onPressed: () => adicionarTarefa(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    itemCount: tarefas.length,
                    itemBuilder: itemBuilder,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget itemBuilder(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          tarefaRemovida = Map.from(tarefas[index]);
          indexTarefaRemovida = index;

          setState(() {
            tarefas.removeAt(index);
            salvarTarefas();
          });

          final snack = SnackBar(
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  "Tarefa ${tarefaRemovida['title'].toUpperCase()} removida!",
                  style: const TextStyle(color: Colors.amberAccent)),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
                label: "Desfazer",
                textColor: Colors.green,
                onPressed: () {
                  setState(() {
                    tarefas.insert(indexTarefaRemovida, tarefaRemovida);
                    salvarTarefas();
                  });
                }),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        },
        background: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment(-.96, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
            boxShadow: const [
              BoxShadow(color: Colors.green, spreadRadius: .8),
            ],
          ),
          child: CheckboxListTile(
            value: tarefas[index]['check'],
            title: Text(tarefas[index]['title']),
            secondary: CircleAvatar(
                child: Visibility(
              visible: tarefas[index]['check'],
              replacement: const Icon(Icons.error_outline),
              child: const Icon(Icons.check),
            )),
            onChanged: (value) {
              setState(() {
                tarefas[index]['check'] = value;
                salvarTarefas();
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 2));

    tarefas.sort((a, b) {
      if (a['check'] && !b['check']) {
        return 1;
      } else if (!a['check'] && !b['check']) {
        return -1;
      } else {
        return 0;
      }
    });

    setState(() {
      salvarTarefas();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<String> lerTarefas() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "";
    }
  }

  Future<File> salvarTarefas() async {
    String data = json.encode(tarefas);
    final file = await _getFile();
    return file.writeAsString(data);
  }
}
