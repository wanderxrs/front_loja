import 'package:flutter/material.dart';
import 'package:projeto_loja/screens/login_page.dart'; // <--- NOME CORRETO DO SEU PACOTE AQUI!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      home: LoginPage(), 
    );
  }
}