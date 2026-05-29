import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'cadastro_itens.dart';
import 'login_page.dart';

class VendedorHomePage extends StatefulWidget {
  final int idVendedor;
  const VendedorHomePage({super.key, required this.idVendedor});

  @override
  State<VendedorHomePage> createState() => _VendedorHomePageState();
}

class _VendedorHomePageState extends State<VendedorHomePage> {
  final api = ServicoApi();
  late Future<List<dynamic>> futureProdutos;

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

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

  // ================= LOGOUT =================
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _mostrarExcluirConta() {
    final TextEditingController senhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text(
          "Excluir Conta",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Esta ação é irreversível. Para confirmar, digite sua senha atual:",
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: senhaController,
              obscureText: true,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              String senhaDigitada = senhaController.text.trim();

              if (senhaDigitada.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("A senha é obrigatória.")),
                );
                return;
              }

              // Captura o mensagem antes de fechar o modal ou mudar de tela
              final mensagem = ScaffoldMessenger.of(context);

              // 1. Fecha o modal de confirmação
              Navigator.pop(context);

              // 2. Chama a API (que você já confirmou que funciona e deleta)
              bool sucesso = await api.deletarConta(widget.idVendedor, senhaDigitada);

              if (sucesso) {
                // 3. Mostra a mensagem de sucesso usando a referência segura
                mensagem.showSnackBar(
                  const SnackBar(
                    content: Text("Sua conta foi excluída com sucesso."),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                // 4. Força o redirecionamento para a tela de login limpando a pilha
                if (mounted) {
                  _logout();
                }
              } else {
                // Se der errado (senha incorreta, por exemplo)
                mensagem.showSnackBar(
                  const SnackBar(
                    content: Text("Erro ao excluir conta, senha incorreta."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Excluir Permanentemente"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Meu Painel de Vendas"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,

        actions: [

          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: "Excluir Conta",
            onPressed: _mostrarExcluirConta,
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CadastroItensPage(idVendedor: widget.idVendedor),
            ),
          );
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
            return Center(
              child: Text(
                "Você não tem produtos cadastrados.",
                style: TextStyle(color: textColor),
              ),
            );
          }

          final produtos = snapshot.data!;

          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final prod = produtos[index];

              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    prod['name'] ?? 'Sem nome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    "Estoque atual: ${prod['stock']}",
                    style: TextStyle(color: textColor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: primaryColor),
                        onPressed: () => _mostrarDialogoEdicao(prod),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmarExclusao(prod['id'], prod['name']),
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
    List<dynamic> categorias = await api.buscarCategorias();

    String categoriaSelecionada =
        prod['category_id']?.toString() ??
        (categorias.isNotEmpty ? categorias.first['id'].toString() : '');

    final nomeController = TextEditingController(text: prod['name']);
    final precoController =
        TextEditingController(text: prod['price'].toString());
    final estoqueController =
        TextEditingController(text: prod['stock'].toString());
    final descController =
        TextEditingController(text: prod['description']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            "Editar Produto",
            style: TextStyle(color: textColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(nomeController, "Nome"),
                const SizedBox(height: 10),
                _buildField(precoController, "Preço", number: true),
                const SizedBox(height: 10),
                _buildField(estoqueController, "Estoque", number: true),
                const SizedBox(height: 10),
                _buildField(descController, "Descrição"),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  dropdownColor: cardColor,
                  value: categoriaSelecionada.isNotEmpty
                      ? categoriaSelecionada
                      : null,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Categoria",
                    labelStyle: TextStyle(color: textColor),
                  ),
                  items: categorias.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id'].toString(),
                      child: Text(
                        cat['name'],
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => categoriaSelecionada = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () async {
                Map<String, dynamic> dadosEditados = {
                  'id': prod['id'],
                  'category_id': categoriaSelecionada,
                  'nome': nomeController.text,
                  'descricao': descController.text,
                  'preco': precoController.text,
                  'estoque': estoqueController.text,
                };

                bool sucesso =
                    await api.editarItem(widget.idVendedor, dadosEditados);

                if (sucesso && mounted) {
                  Navigator.pop(context);
                  _atualizarProdutos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Produto atualizado!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erro ao editar.")),
                  );
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
        backgroundColor: cardColor,
        title: Text("Excluir Produto?",
            style: TextStyle(color: textColor)),
        content: Text(
          "Deseja realmente apagar o produto '$nome'?",
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              bool sucesso =
                  await api.excluirItem(widget.idVendedor, idProduto);

              if (sucesso) {
                _atualizarProdutos();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Produto removido!")),
                );
              }
            },
            child: const Text("Excluir",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool number = false}) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        border: const OutlineInputBorder(),
      ),
    );
  }
}