import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicoApi {
  final String baseUrl = "http://127.0.0.1:5000";

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": senha}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      print("Erro login: ${response.body}");
      return null;
    } catch (e) {
      print("Erro conexão login: $e");
      return null;
    }
  }

  // ================= CADASTRO =================
  Future<bool> cadastrarUsuario(
    String nome,
    String email,
    String senha,
    String userType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/registro"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nome,
          "email": email,
          "password": senha,
          "user_type": userType,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Erro cadastro: $e");
      return false;
    }
  }

  // ================= RECUPERAR SENHA =================
  Future<bool> recuperarSenha(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/recuperarSenha"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      print("RECUPERAR STATUS: ${response.statusCode}");
      print("RECUPERAR BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Erro recuperar senha: $e");
      return false;
    }
  }

  // ================= VERIFICAR CÓDIGO =================
  Future<bool> verificarCodigo(String codigo) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verificarCodigo"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"codigo": codigo}),
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

  // ================= REDEFINIR SENHA =================
  Future<bool> redefinirSenha(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/redefinirSenha"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "senha": senha}),
      );

      print("REDEFINIR STATUS: ${response.statusCode}");
      print("REDEFINIR BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Erro redefinir senha: $e");
      return false;
    }
  }

  // ================= PRODUTOS =================
  Future<List<dynamic>> buscarProdutos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/listarProdutos'));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Erro buscar produtos: $e");
    }

    return [];
  }

  // ================= COMPRAR ITEM =================
  Future<bool> comprarItem(int userId, int productId, int quantidade) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comprarItem'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fkUser": userId,
          "id": productId,
          "quantidade": quantidade,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Erro compra: $e");
      return false;
    }
  }

  // ================= CADASTRAR ITEM =================
  Future<bool> cadastrarNovoItem(
    String fkUser,
    String categoryId,
    String nome,
    String descricao,
    String preco,
    String estoque,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cadastrarItem'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fkUser": fkUser,
          "category_id": categoryId,
          "nome": nome,
          "descricao": descricao,
          "preco": preco,
          "estoque": estoque,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Erro cadastrar item: $e");
      return false;
    }
  }

  // ================= PRODUTOS DO VENDEDOR =================
  Future<List<dynamic>> buscarProdutosVendedor(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/listarProdutosVendedor?userId=$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Erro produtos vendedor: $e");
    }

    return [];
  }

  // ================= EDITAR ITEM =================
  Future<bool> editarItem(int idVendedor, Map<String, dynamic> dados) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/editarItem'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'fkUser': idVendedor,
          'id': dados['id'],
          'category_id': dados['category_id'],
          'nomeProduto': dados['nome'],
          'descProd': dados['descricao'],
          'precoProd': dados['preco'],
          'estoqueProd': dados['estoque'],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Erro editar item: $e");
      return false;
    }
  }

  // ================= EXCLUIR ITEM =================
  Future<bool> excluirItem(int idVendedor, int idProduto) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/excluirItem'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'fkUser': idVendedor, 'id': idProduto}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Erro excluir item: $e");
      return false;
    }
  }

  // Adicione isto dentro da classe ServicoApi no seu arquivo api_connect.dart
  Future<List<dynamic>> buscarCategorias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/listarCategorias'));

      if (response.statusCode == 200) {
        // O jsonDecode transforma o JSON do Flask em uma lista do Dart
        return jsonDecode(response.body);
      } else {
        print("Erro na API: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erro ao conectar com a API: $e");
      return [];
    }
  }
}
