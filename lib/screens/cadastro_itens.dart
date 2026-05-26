import 'package:flutter/material.dart';
import '../services/api_connect.dart';

class CadastroItensPage extends StatefulWidget {
  final int idVendedor;
  const CadastroItensPage({super.key, required this.idVendedor});

  @override
  State<CadastroItensPage> createState() => _CadastroItensPageState();
}

class _CadastroItensPageState extends State<CadastroItensPage> {
  final api = ServicoApi();
  final nomeController = TextEditingController();
  final descController = TextEditingController();
  final precoController = TextEditingController();
  final estoqueController = TextEditingController();

  List<dynamic> _categorias = [];
  String? _categoriaSelecionada; // Armazena o ID da categoria escolhida
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final dados = await api.buscarCategorias();
    setState(() {
      _categorias = dados;
    });
  }

  Future<void> enviarCadastro() async {
    if (nomeController.text.isEmpty ||
        precoController.text.isEmpty ||
        _categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos e selecione uma categoria!"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    bool sucesso = await api.cadastrarNovoItem(
      widget.idVendedor.toString(),
      _categoriaSelecionada!, // Envia o ID selecionado
      nomeController.text,
      descController.text,
      precoController.text,
      estoqueController.text,
    );

    setState(() => isLoading = false);

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto cadastrado com sucesso!")),
      );
      Navigator.pop(context); // Volta para a página do vendedor
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar produto.")),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Produto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome do Produto"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              TextField(
                controller: precoController,
                decoration: const InputDecoration(labelText: "Preço"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: estoqueController,
                decoration: const InputDecoration(labelText: "Estoque"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 15),

              // CAMPO CORRIGIDO:
              _categorias.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _categoriaSelecionada,
                      decoration: const InputDecoration(
                        labelText: "Selecione a Categoria",
                        border: OutlineInputBorder(),
                      ),
                      items: _categorias.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'].toString(),
                          child: Text(cat['name'].toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoriaSelecionada = value;
                        });
                      },
                    ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : enviarCadastro,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Cadastrar Produto"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
