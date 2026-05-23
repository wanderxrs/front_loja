import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicoApi {

  final String baseUrl = "http://127.0.0.1:5000";


  // ================= REGISTRO =================
  Future<bool> cadastrarUsuario(String nome, String email, String senha) async {
    final response = await http.post(
      Uri.parse("$baseUrl/registro"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "nome": nome,
        "email": email,
        "password": senha
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "password": senha
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(jsonDecode(response.body));
      return null;
    }
  }
}