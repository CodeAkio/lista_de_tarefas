import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/modules/home/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Lista de Tarefas",
      home: HomePage(),
    );
  }
}
