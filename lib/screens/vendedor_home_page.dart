import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _checarSeguranca();
    _atualizarProdutos();
  }

  Future<void> _checarSeguranca() async {
    bool sessaoAtiva = await api.verificarSessao(widget.idVendedor);

    if (!sessaoAtiva && mounted) {
      // redireciona para o login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _atualizarProdutos() {
    setState(() {
      futureProdutos = api.buscarProdutosVendedor(widget.idVendedor);
    });
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    // 1. Opcional: Mostrar um loading enquanto desconecta
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // LOGOUT. Chama a API para registrar o logoff no servidor
    await api.realizarLogoff();

    // Limpa o armazenamento local
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Remove o loading e manda para o Login
    if (mounted) {
      Navigator.pop(context); // Fecha o loading
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              String senhaDigitada = senhaController.text.trim();

              if (senhaDigitada.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("A senha é obrigatória.")),
                );
                return;
              }

              final mensagem = ScaffoldMessenger.of(context);

              Navigator.pop(context);

              bool sucesso = await api.deletarConta(
                widget.idVendedor,
                senhaDigitada,
              );

              if (sucesso) {
                mensagem.showSnackBar(
                  const SnackBar(
                    content: Text("Sua conta foi excluída com sucesso."),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                if (mounted) {
                  _logout();
                }
              } else {
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

  // ================= MÉTODO BUILD =================
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
                        onPressed: () => _edicaoCategoria(prod),
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

  // ================= MÉTODOS DE MEXER NA CATEGORIA =================

  void _edicaoCategoria(Map<String, dynamic> prod) async {
    List<dynamic> categorias = await api.buscarCategoriasPorVendedor(
      widget.idVendedor,
    );

    String categoriaSelecionada =
        prod['category_id']?.toString() ??
        (categorias.isNotEmpty ? categorias.first['id'].toString() : '');

    final nomeController = TextEditingController(text: prod['name']);
    final precoController = TextEditingController(
      text: prod['price'].toString(),
    );
    final estoqueController = TextEditingController(
      text: prod['stock'].toString(),
    );
    final descController = TextEditingController(text: prod['description']);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cardColor,
          title: Text("Editar Produto", style: TextStyle(color: textColor)),
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

                // DROPDOWN DE SELEÇÃO
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
                        cat['name'] +
                            (cat['user_id'] != null ? " (Minha)" : ""),
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => categoriaSelecionada = value!),
                ),
                const SizedBox(height: 10),

                // ================= GERENCIADOR (POST, PUT, DELETE) =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //  Criar Categoria
                    TextButton.icon(
                      icon: Icon(Icons.add, color: primaryColor),
                      label: Text(
                        "Criar",
                        style: TextStyle(color: primaryColor),
                      ),
                      onPressed: () async {
                        final textCtrl = TextEditingController();
                        String? nome = await _promptTexto(
                          "Nova Categoria",
                          textCtrl,
                        );
                        if (nome != null && nome.isNotEmpty) {
                          if (await api.criarCategoria(
                            widget.idVendedor,
                            nome,
                          )) {
                            var atualizadas = await api
                                .buscarCategoriasPorVendedor(widget.idVendedor);
                            setDialogState(() {
                              categorias = atualizadas;
                              categoriaSelecionada = categorias
                                  .firstWhere((c) => c['name'] == nome)['id']
                                  .toString();
                            });
                          }
                        }
                      },
                    ),
                    //  Editar Categoria Selecionada (Apenas se for dele)
                    TextButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text(
                        "Editar",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () async {
                        final atual = categorias.firstWhere(
                          (c) => c['id'].toString() == categoriaSelecionada,
                          orElse: () => null,
                        );
                        if (atual == null || atual['user_id'] == null) return;

                        final textCtrl = TextEditingController(
                          text: atual['name'],
                        );
                        String? novoNome = await _promptTexto(
                          "Editar Nome",
                          textCtrl,
                        );
                        if (novoNome != null && novoNome.isNotEmpty) {
                          if (await api.editarCategoria(
                            atual['id'],
                            widget.idVendedor,
                            novoNome,
                          )) {
                            var atualizadas = await api
                                .buscarCategoriasPorVendedor(widget.idVendedor);
                            setDialogState(() => categorias = atualizadas);
                          }
                        }
                      },
                    ),
                    //  Deletar Categoria Selecionada (Apenas se for dele)
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Apagar",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        final atual = categorias.firstWhere(
                          (c) => c['id'].toString() == categoriaSelecionada,
                          orElse: () => null,
                        );
                        if (atual == null || atual['user_id'] == null) return;

                        if (await api.deletarCategoria(
                          atual['id'],
                          widget.idVendedor,
                        )) {
                          var atualizadas = await api
                              .buscarCategoriasPorVendedor(widget.idVendedor);
                          setDialogState(() {
                            categorias = atualizadas;
                            categoriaSelecionada = categorias.isNotEmpty
                                ? categorias.first['id'].toString()
                                : '';
                          });
                        }
                      },
                    ),
                  ],
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
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                Map<String, dynamic> dadosEditados = {
                  'id': prod['id'],
                  'category_id': categoriaSelecionada,
                  'nome': nomeController.text,
                  'descricao': descController.text,
                  'preco': precoController.text,
                  'estoque': estoqueController.text,
                };

                if (await api.editarItem(widget.idVendedor, dadosEditados) &&
                    mounted) {
                  Navigator.pop(context);
                  _atualizarProdutos();
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

  // ADICIONADO: Método que estava faltando para o funcionamento do botão de apagar produto
  void _confirmarExclusao(int idProduto, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text("Excluir Produto?", style: TextStyle(color: textColor)),
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
              bool sucesso = await api.excluirItem(
                widget.idVendedor,
                idProduto,
              );

              if (sucesso) {
                _atualizarProdutos();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Produto removido!")),
                  );
                }
              }
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper simples para abrir a caixinha de texto para Criar/Editar a categoria
  Future<String?> _promptTexto(String titulo, TextEditingController ctrl) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(titulo, style: TextStyle(color: textColor)),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: textColor),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Sair"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
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
