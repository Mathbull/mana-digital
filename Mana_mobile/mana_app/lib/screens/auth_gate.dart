import 'package:flutter/material.dart';

import '../services/token_service.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'home.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    
    final token = await TokenService.getToken();

    
    if (token == null || token.isEmpty) {
      _goToLogin();
      return;
    }

    try {
      final response = await ApiService.getMe();

      if (response.statusCode == 200) {
        // Token válido

        _goToHome();

      } else {
        // Token inválido ou expirado

        await TokenService.deleteToken();

        _goToLogin();
      }
    } catch (e) {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _goToHome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeDashboardScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}