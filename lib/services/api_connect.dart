import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicoApi {

  final String baseUrl = "http://127.0.0.1:5000";

  // ================= REGISTRO =================
  Future<bool> cadastrarUsuario(String nome, String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/registro"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nome,
          "email": email,
          "password": senha
        }),
      );

      return response.statusCode == 201;

    } catch (e) {
      print("Erro registro: $e");
      return false;
    }
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": senha
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;

    } catch (e) {
      print("Erro login: $e");
      return null;
    }
  }

  // ================= RECUPERAR SENHA =================
  Future<bool> recuperarSenha(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/recuperarSenha"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email
        }),
      );

      print("RECUPERAR STATUS: ${response.statusCode}");
      print("RECUPERAR BODY: ${response.body}");

      return response.statusCode == 200;

    } catch (e) {
      print("Erro recuperar senha: $e");
      return false;
    }
  }

  // ================= VERIFICAR CÓDIGO (CORRIGIDO) =================
  Future<bool> verificarCodigo(String codigo) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verificarCodigo"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "codigo": codigo
        }),
      );

      print("VERIFICAR STATUS: ${response.statusCode}");
      print("VERIFICAR BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["valido"] == true;
      }

      return false;

    } catch (e) {
      print("Erro verificar codigo: $e");
      return false;
    }
  }

  //================== NOVA SENHA =================
  Future<bool> redefinirSenha(String email, String senha) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/redefinirSenha"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "senha": senha,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 200;

  } catch (e) {
    print("ERRO: $e");
    return false;
  }

}
}