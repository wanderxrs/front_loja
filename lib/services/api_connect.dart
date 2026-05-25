import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicoApi {
  final String baseUrl = "http://127.0.0.1:5000";

  // Login
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": senha}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("Erro Login: $e");
    }
    return null;
  }

  // Cadastro de Usuário
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
      print("Erro Cadastro: $e");
      return false;
    }
  }

  // Buscar Produtos
  Future<List<dynamic>> buscarProdutos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/listarProdutos'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Erro Buscar Produtos: $e");
    }
    return [];
  }

  // Comprar Item
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
      print("Erro Compra: $e");
      return false;
    }
  }

  // CADASTRO DE ITEM (AJUSTADO PARA IGUALAR AO POSTMAN)
  Future<bool> cadastrarNovoItem(
    String fkUser,
    String category_id,
    String nome,
    String descProd,
    String precoProd,
    String estoqueProd,
  ) async {
    try {
      final bodyData = {
        "fkUser": fkUser, // O Flask busca 'fkUser'
        "category_id": category_id, // O Flask busca 'category_id'
        "nome": nome, // O Flask busca 'nome'
        "descricao": descProd, // O Flask busca 'descricao'
        "preco": precoProd, // O Flask busca 'preco'
        "estoque": estoqueProd, // O Flask busca 'estoque'
      };

      final response = await http.post(
        Uri.parse('$baseUrl/cadastrarItem'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      // Status 201 é criado com sucesso
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Erro no envio do item: $e");
      return false;
    }
  }

  // Buscar apenas os produtos do vendedor logado
  Future<List<dynamic>> buscarProdutosVendedor(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/listarProdutosVendedor?userId=$userId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Erro ao listar produtos do vendedor: $e");
    }
    return [];
  }

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
      print("Erro ao editar: $e");
      return false;
    }
  }

  Future<bool> excluirItem(int idVendedor, int idProduto) async {
    try {
      // Note que usamos 'delete' aqui, conforme sua rota @app.route('/excluirItem', methods=['DELETE'])
      final response = await http.delete(
        Uri.parse('$baseUrl/excluirItem'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'fkUser': idVendedor, 'id': idProduto}),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Erro ao excluir: $e");
    }
    return false;
  }
}
