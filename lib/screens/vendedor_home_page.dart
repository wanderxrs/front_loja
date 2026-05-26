import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'cadastro_itens.dart';

class VendedorHomePage extends StatefulWidget {
  final int idVendedor;
  const VendedorHomePage({super.key, required this.idVendedor});

  @override
  State<VendedorHomePage> createState() => _VendedorHomePageState();
}

class _VendedorHomePageState extends State<VendedorHomePage> {
  final api = ServicoApi();
  late Future<List<dynamic>> futureProdutos;

  @override
  void initState() {
    super.initState();
    _atualizarProdutos();
  }

  void _atualizarProdutos() {
    setState(() {
      futureProdutos = api.buscarProdutosVendedor(widget.idVendedor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Painel de Vendas")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => CadastroItensPage(idVendedor: widget.idVendedor)
          ));
          _atualizarProdutos();
        },
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Você não tem produtos cadastrados."));
          }

          final produtos = snapshot.data!;
          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final prod = produtos[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(prod['name'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Estoque atual: ${prod['stock']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogoEdicao(prod),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusao(prod['id'], prod['name']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogoEdicao(Map<String, dynamic> prod) async {
    // Busca categorias para o Dropdown
    List<dynamic> categorias = await api.buscarCategorias();
    
    print("DEBUG: Total de categorias recebidas: ${categorias.length}");
    print("DEBUG: Conteúdo: $categorias");

    if (categorias.isEmpty) {
      print("DEBUG: ERRO - Lista vazia!");
    }

    // Define a categoria atual do produto
    String categoriaSelecionada = prod['category_id']?.toString() ?? 
                                  (categorias.isNotEmpty ? categorias.first['id'].toString() : '');

    final nomeController = TextEditingController(text: prod['name']);
    final precoController = TextEditingController(text: prod['price'].toString());
    final estoqueController = TextEditingController(text: prod['stock'].toString());
    final descController = TextEditingController(text: prod['description']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Editar Produto"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome")),
                TextField(controller: precoController, decoration: const InputDecoration(labelText: "Preço")),
                TextField(controller: estoqueController, decoration: const InputDecoration(labelText: "Estoque")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: categoriaSelecionada.isNotEmpty ? categoriaSelecionada : null,
                  decoration: const InputDecoration(labelText: "Categoria"),
                  items: categorias.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id'].toString(),
                      child: Text("${cat['name']} (ID: ${cat['id']})"),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => categoriaSelecionada = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> dadosEditados = {
                  'id': prod['id'],
                  'category_id': categoriaSelecionada,
                  'nome': nomeController.text,
                  'descricao': descController.text,
                  'preco': precoController.text,
                  'estoque': estoqueController.text,
                };

                bool sucesso = await api.editarItem(widget.idVendedor, dadosEditados);
                
                if (sucesso && mounted) {
                  Navigator.pop(context);
                  _atualizarProdutos();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto atualizado!")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao editar.")));
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(int idProduto, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Produto?"),
        content: Text("Deseja realmente apagar o produto '$nome'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              bool sucesso = await api.excluirItem(widget.idVendedor, idProduto);
              if (sucesso) {
                _atualizarProdutos();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto removido!")));
              }
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}