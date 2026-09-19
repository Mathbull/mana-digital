import 'package:flutter/material.dart';

class LeiturasScreen extends StatelessWidget {
  const LeiturasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leituras'),
      ),
      body: const Center(
        child: Text('Tela de Leituras'),
      ),
    );
  }
}