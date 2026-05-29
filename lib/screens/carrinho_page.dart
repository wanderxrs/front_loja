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

  Future<void> _carregarCarrinho() async {
    setState(() => carregando = true);

    final data = await api.listarCarrinho(widget.idUsuario);

    print("🔥 ITENS DO CARRINHO:");
    print(data);

    setState(() {
      itens = data;
      carregando = false;
    });
  }

  Future<void> _removerItem(int id) async {
    print("🗑️ Removendo ID: $id");

    await api.removerCarrinho(id);

    await _carregarCarrinho();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item removido")),
      );
    }
  }

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

                    final String preco =
                        item['price']?.toString() ?? '0.00';

                    final String quantidade =
                        item['quantity']?.toString() ?? '0';

                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          nome,
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          "R\$ $preco x $quantidade",
                          style: TextStyle(color: textColor),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: primaryColor),
                          onPressed: id == 0
                              ? null
                              : () => _removerItem(id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}