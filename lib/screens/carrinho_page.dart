import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'carrinho_controller.dart';

class CarrinhoPage extends StatefulWidget {
  final int idUsuario;

  const CarrinhoPage({super.key, required this.idUsuario});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  final carrinho = CarrinhoController();
  final api = ServicoApi();

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

  Future<void> removerItem(int index) async {
    final item = carrinho.itens[index];

    int quantidade = item['quantidade'];

    bool sucesso = await api.comprarItem(
      widget.idUsuario,
      item['id'],
      -quantidade,
    );

    if (sucesso) {
      setState(() {
        carrinho.removerItem(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item removido e estoque devolvido!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao atualizar banco")),
      );
    }
  }

  void diminuirQuantidade(int index) async {
    final item = carrinho.itens[index];

    bool sucesso = await api.comprarItem(
      widget.idUsuario,
      item['id'],
      -1,
    );

    if (sucesso) {
      setState(() {
        carrinho.diminuirQuantidade(index);
      });
    }
  }

  void aumentarQuantidade(int index) async {
    final item = carrinho.itens[index];

    bool sucesso = await api.comprarItem(
      widget.idUsuario,
      item['id'],
      1,
    );

    if (sucesso) {
      setState(() {
        carrinho.aumentarQuantidade(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Meu Carrinho"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      body: carrinho.itens.isEmpty
          ? Center(
              child: Text(
                "Carrinho vazio",
                style: TextStyle(color: textColor),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: carrinho.itens.length,
                    itemBuilder: (context, index) {
                      final item = carrinho.itens[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            item['nome'],
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "R\$ ${item['preco']}",
                                style: TextStyle(color: textColor),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.red),
                                    onPressed: () => diminuirQuantidade(index),
                                  ),
                                  Text(
                                    "${item['quantidade']}",
                                    style: TextStyle(color: textColor),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.green),
                                    onPressed: () => aumentarQuantidade(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removerItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Total: R\$ ${carrinho.total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
    );
  }
}