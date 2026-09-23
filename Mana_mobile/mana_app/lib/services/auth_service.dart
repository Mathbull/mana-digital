import 'token_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '/models/content_item.dart';
import '/models/game.dart';
import '/models/game_details.dart';
import '/models/iniciativa.dart';

class ApiService {

  static const String baseUrl = 'http://10.0.2.2:5273';

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

  static Future<http.Response> getLeituras() async {
    final token = await TokenService.getToken();

    return await http.get(
      Uri.parse('$baseUrl/api/leituras'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<List<ContentItem>> fetchLeituras() async {
    final response = await getLeituras();

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar leituras: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final lista = data['leituras'] as List<dynamic>? ?? [];

    return lista
        .map(
          (item) => ContentItem.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
  static Future<http.Response> responderLeitura({
    required String leituraId,
    required Map<String, bool> respostas,
  }) async {
    final token = await TokenService.getToken();

    return await http.post(
      Uri.parse('$baseUrl/api/leituras/responder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'leituraId': leituraId,
        'respostas': respostas,
      }),
    );
  }

  static Future<http.Response> getJogos() async {
    final token = await TokenService.getToken();

    return await http.get(
      Uri.parse('$baseUrl/api/jogos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<List<Game>> fetchJogos() async {
    final response = await getJogos();

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar jogos: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final lista = data['jogos'] as List<dynamic>? ?? [];

    return lista
        .map(
          (item) => Game.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Future<http.Response> finalizarJogo({
    required String gameId,
    required Map<String, String> respostasSelecionadas,
  }) async {
    final token = await TokenService.getToken();

    return await http.post(
      Uri.parse('$baseUrl/api/jogos/finalizar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'gameId': gameId,
        'respostasSelecionadas': respostasSelecionadas,
      }),
    );
  }
  
  static Future<GameDetails> fetchJogo(String gameId) async {
    final token = await TokenService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/jogos/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar jogo: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return GameDetails.fromJson(data);
  }

  static Future<http.Response> getIniciativas() async {
    final token = await TokenService.getToken();

    return await http.get(
      Uri.parse('$baseUrl/api/iniciativas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
  static Future<List<Iniciativa>> fetchIniciativas() async {
    final response = await getIniciativas();

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar iniciativas: ${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final lista =
        data['iniciativas'] as List<dynamic>? ?? [];

    return lista
        .map(
          (item) => Iniciativa.fromJson(
            item as Map<String, dynamic>,
          ),
          )
        .toList();
  }

  static Future<http.Response> submeterIniciativa({
    required String tipo,
    String? titulo,
    String? descricao,
    String? anexoUrl,
    String? emailIndicado,
  }) async {
    final token = await TokenService.getToken();

    return await http.post(
      Uri.parse('$baseUrl/api/iniciativas/submeter'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tipo': tipo,
        'titulo': titulo ?? '',
        'descricao': descricao ?? '',
        'anexoUrl': anexoUrl,
        'emailIndicado': emailIndicado,
      }),
    );
  }

  static Future<Iniciativa> enviarIniciativa({
    required String tipo,
    String? titulo,
    String? descricao,
    String? anexoUrl,
    String? emailIndicado,
  }) async {
    final response = await submeterIniciativa(
      tipo: tipo,
      titulo: titulo,
      descricao: descricao,
      anexoUrl: anexoUrl,
      emailIndicado: emailIndicado,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String mensagem =
          'Não foi possível enviar a iniciativa.';

      try {
        final data =
            jsonDecode(response.body)
                as Map<String, dynamic>;

        mensagem =
            data['message']?.toString() ??
                mensagem;
      } catch (_) {}

      throw Exception(mensagem);
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final iniciativaJson =
        data['iniciativa'];

    if (iniciativaJson is! Map<String, dynamic>) {
      throw Exception(
        'Resposta inválida da API.',
      );
    }

    return Iniciativa.fromJson(
      iniciativaJson,
    );
  }
}