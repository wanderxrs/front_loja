import 'package:flutter/material.dart';
import '../services/api_connect.dart';

class CarrinhoPage extends StatefulWidget {
  final int idUsuario;

  const CarrinhoPage({super.key, required this.idUsuario});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  final api = ServicoApi();

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

  List<dynamic> itens = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCarrinho();
  }

  // ================= CARREGAR =================
  Future<void> _carregarCarrinho() async {
    setState(() => carregando = true);

    final data = await api.listarCarrinho(widget.idUsuario);

    setState(() {
      itens = data;
      carregando = false;
    });
  }

  // ================= REMOVER =================
  Future<void> _removerItem(int id) async {
    await api.removerCarrinho(id);
    await _carregarCarrinho();
  }

  // ================= ALTERAR QUANTIDADE =================
  Future<void> _alterarQuantidade(int id, int qtdAtual, int delta) async {
    final novaQtd = qtdAtual + delta;

    if (novaQtd <= 0) {
      await _removerItem(id);
      return;
    }

    await api.atualizarQuantidade(id, novaQtd);
    await _carregarCarrinho();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Carrinho"),
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        centerTitle: true,
      ),

      body: carregando
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : itens.isEmpty
              ? Center(
                  child: Text(
                    "Carrinho vazio",
                    style: TextStyle(color: textColor),
                  ),
                )
              : ListView.builder(
                  itemCount: itens.length,
                  itemBuilder: (context, index) {
                    final item = itens[index];

                    final int id =
                        int.tryParse(item['id'].toString()) ?? 0;

                    final String nome =
                        item['name']?.toString() ?? 'Sem nome';

                    final double preco =
                        double.tryParse(item['price'].toString()) ?? 0;

                    final int quantidade =
                        int.tryParse(item['quantity'].toString()) ?? 0;

                    return Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nome,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "R\$ ${preco.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CONTROLE DE QUANTIDADE
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove,
                                    color: primaryColor),
                                onPressed: () =>
                                    _alterarQuantidade(
                                        id, quantidade, -1),
                              ),
                              Text(
                                quantidade.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add,
                                    color: primaryColor),
                                onPressed: () =>
                                    _alterarQuantidade(
                                        id, quantidade, 1),
                              ),
                            ],
                          ),

                          // REMOVER
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _removerItem(id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}