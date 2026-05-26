import 'package:flutter/material.dart';
import '../services/api_connect.dart';

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
  String? _categoriaSelecionada = "0"; // Inicializado em "Todas"

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
        _produtosFiltrados = _todosProdutos.where((p) => 
          p['category_id'].toString() == idCategoria
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loja Virtual")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Filtrar por Categoria", border: OutlineInputBorder()),
              value: _categoriaSelecionada,
              items: [
                const DropdownMenuItem(value: "0", child: Text("Todas as categorias")),
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
                ? const Center(child: Text("Nenhum produto encontrado."))
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
    final int idProduto = prod['id'] ?? 0;
    final int estoque = prod['stock'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("R\$ $preco"),
            Text("Estoque: $estoque", style: TextStyle(color: estoque > 0 ? Colors.green : Colors.red)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: estoque > 0 ? () => _mostrarDialogoCompra(prod) : null,
          child: const Text("Comprar"),
        ),
      ),
    );
  }

  void _mostrarDialogoCompra(dynamic prod) {
    int quantidadeEscolhida = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Comprar ${prod['name']}"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: quantidadeEscolhida > 1 ? () => setDialogState(() => quantidadeEscolhida--) : null,
              ),
              Text("$quantidadeEscolhida", style: const TextStyle(fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: quantidadeEscolhida < prod['stock'] ? () => setDialogState(() => quantidadeEscolhida++) : null,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                bool sucesso = await api.comprarItem(widget.idUsuario, prod['id'], quantidadeEscolhida);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(sucesso ? "Compra realizada!" : "Erro na compra."),
                  ));
                  if (sucesso) _carregarDados();
                }
              },
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }
}