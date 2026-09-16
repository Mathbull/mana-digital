import 'package:flutter/material.dart';

class JogosScreen extends StatelessWidget {
  const JogosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogos'),
      ),
      body: const Center(
        child: Text('Tela de Jogos'),
      ),
    );
  }
}