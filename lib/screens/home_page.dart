import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'carrinho_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final int idUsuario;
  const HomePage({super.key, required this.idUsuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ServicoApi();

  List<dynamic> _todosProdutos = [];
  List<dynamic> _produtosFiltrados = [];
  List<dynamic> _categorias = [];
  String? _categoriaSelecionada = "0";

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prods = await api.buscarProdutos();
    final cats = await api.buscarCategorias();

    setState(() {
      _todosProdutos = prods;
      _produtosFiltrados = prods;
      _categorias = cats;
    });
  }

  void _filtrarPorCategoria(String? idCategoria) {
    setState(() {
      _categoriaSelecionada = idCategoria;

      if (idCategoria == null || idCategoria == "0") {
        _produtosFiltrados = _todosProdutos;
      } else {
        _produtosFiltrados = _todosProdutos
            .where((p) => p['category_id'].toString() == idCategoria)
            .toList();
      }
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("MARKETX"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: primaryColor),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarrinhoPage(
                    idUsuario: widget.idUsuario,
                  ),
                ),
              );

              _carregarDados();
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              dropdownColor: cardColor,
              value: _categoriaSelecionada,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Filtrar por Categoria",
                labelStyle: TextStyle(color: textColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: "0",
                  child: Text("Todas as categorias"),
                ),
                ..._categorias.map((cat) => DropdownMenuItem(
                      value: cat['id'].toString(),
                      child: Text(cat['name']),
                    )),
              ],
              onChanged: _filtrarPorCategoria,
            ),
          ),

          Expanded(
            child: _produtosFiltrados.isEmpty
                ? Center(
                    child: Text(
                      "Nenhum produto encontrado.",
                      style: TextStyle(color: textColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: _produtosFiltrados.length,
                    itemBuilder: (context, index) {
                      final prod = _produtosFiltrados[index];
                      return _buildProdutoCard(prod);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdutoCard(dynamic prod) {
    final String nome = prod['name']?.toString() ?? 'Sem nome';
    final String preco = prod['price']?.toString() ?? '0.00';
    final int estoque = int.tryParse(prod['stock'].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: ListTile(
        title: Text(
          nome,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("R\$ $preco", style: TextStyle(color: textColor)),
            Text(
              "Estoque: $estoque",
              style: TextStyle(
                color: estoque > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          onPressed: estoque > 0 ? () {} : null,
          child: const Text("Comprar"),
        ),
      ),
    );
  }
}