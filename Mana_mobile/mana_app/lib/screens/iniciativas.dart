import 'package:flutter/material.dart';

class IniciativasScreen extends StatelessWidget {
  const IniciativasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciativas'),
      ),
      body: const Center(
        child: Text('Tela de Iniciativas'),
      ),
    );
  }
} 