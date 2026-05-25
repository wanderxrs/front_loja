import 'package:flutter/material.dart';
import '../services/api_connect.dart';

class CadastroItensPage extends StatefulWidget {
  final int idVendedor;
  const CadastroItensPage({super.key, required this.idVendedor});

  @override
  State<CadastroItensPage> createState() => _CadastroItensPageState();
}

class _CadastroItensPageState extends State<CadastroItensPage> {
  final nomeController = TextEditingController();
  final descController = TextEditingController();
  final precoController = TextEditingController();
  final estoqueController = TextEditingController();
  final catController = TextEditingController(); // ID da Categoria
  bool isLoading = false;

  Future<void> enviarCadastro() async {
    if (nomeController.text.isEmpty || precoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha nome e preço!")));
      return;
    }

    setState(() => isLoading = true);
    
    final api = ServicoApi();
    
    // Chamada do método de cadastro de item
    bool sucesso = await api.cadastrarNovoItem(
      widget.idVendedor.toString(),
      catController.text,
      nomeController.text,
      descController.text,
      precoController.text,
      estoqueController.text,
    );

    setState(() => isLoading = false);

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto cadastrado com sucesso!")));
      // Limpa os campos
      nomeController.clear();
      precoController.clear();
      descController.clear();
      estoqueController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao cadastrar produto.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Produto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome do Produto")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Descrição")),
              TextField(controller: precoController, decoration: const InputDecoration(labelText: "Preço"), keyboardType: TextInputType.number),
              TextField(controller: estoqueController, decoration: const InputDecoration(labelText: "Estoque"), keyboardType: TextInputType.number),
              TextField(controller: catController, decoration: const InputDecoration(labelText: "ID Categoria")),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : enviarCadastro,
                child: isLoading ? const CircularProgressIndicator() : const Text("Cadastrar Produto"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}