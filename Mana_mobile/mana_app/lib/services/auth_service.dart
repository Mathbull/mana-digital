import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiService {

  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<http.Response> login(
      String email,
      String password,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> register(
      String name,
      String email,
      String password,
  ) async {
    return await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  static Future<http.Response> getMe() async {
    final token = await TokenService.getToken();

    return await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getHome() async {
    final token = await TokenService.getToken();

    return await http.get(
      Uri.parse('$baseUrl/api/home'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}