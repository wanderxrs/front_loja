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
  String? _categoriaSelecionada;
  bool isLoading = false;

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

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
      _categoriaSelecionada!,
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
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar produto.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Cadastrar Produto"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [

              _buildField(nomeController, "Nome do Produto"),
              const SizedBox(height: 10),

              _buildField(descController, "Descrição"),
              const SizedBox(height: 10),

              _buildField(precoController, "Preço", number: true),
              const SizedBox(height: 10),

              _buildField(estoqueController, "Estoque", number: true),

              const SizedBox(height: 15),

              _categorias.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      dropdownColor: cardColor,
                      value: _categoriaSelecionada,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Selecione a Categoria",
                        labelStyle: TextStyle(color: textColor),
                        border: const OutlineInputBorder(),
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : enviarCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Cadastrar Produto",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
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