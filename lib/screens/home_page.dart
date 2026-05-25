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
  late Future<List<dynamic>> futureProdutos;

  @override
  void initState() {
    super.initState();
    futureProdutos = api.buscarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loja Virtual")),
      body: FutureBuilder<List<dynamic>>(
        future: futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum produto disponível."));
          }

          final produtos = snapshot.data!;
          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final prod = produtos[index];
              
              final String nome = prod['name']?.toString() ?? 'Sem nome';
              final String preco = prod['price']?.toString() ?? '0.00';
              final int idProduto = prod['id'] ?? 0;
              final String imageUrl = prod['image_url'] ?? '';
              final int estoque = prod['stock'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                        : const Icon(Icons.shopping_bag),
                  ),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("R\$ $preco"),
                      Text("Estoque: $estoque", style: TextStyle(color: estoque > 0 ? Colors.green : Colors.red)),
                    ],
                  ),
                  // Substitua o ElevatedButton atual dentro do ListTile por este:
trailing: ElevatedButton(
  onPressed: estoque > 0
      ? () {
          int quantidadeEscolhida = 1; // Quantidade inicial

          showDialog(
            context: context,
            builder: (BuildContext context) {
              // StatefulBuilder permite atualizar o número dentro do diálogo
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    title: const Text("Confirmar Compra"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Deseja comprar '$nome'?"),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: quantidadeEscolhida > 1
                                  ? () => setDialogState(() => quantidadeEscolhida--)
                                  : null,
                            ),
                            Text("$quantidadeEscolhida", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: quantidadeEscolhida < estoque
                                  ? () => setDialogState(() => quantidadeEscolhida++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancelar"),
                      ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            
                                            // AQUI: Passamos a quantidadeEscolhida para a API
                                            // (Certifique-se de que sua função comprarItem no api_connect aceite este parâmetro)
                                            bool sucesso = await api.comprarItem(widget.idUsuario, idProduto, quantidadeEscolhida);
                                            
                                            if (mounted && sucesso) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Compra realizada com sucesso!")),
                                              );
                                              setState(() { futureProdutos = api.buscarProdutos(); });
                                            } else if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Erro ao realizar compra.")),
                                              );
                                            }
                                          },
                                          child: const Text("Confirmar"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        : null,
                    child: const Text("Comprar"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}