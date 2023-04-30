import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/pages/android/home_android_page.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeAndroidPage(),
    ),
  );
}
