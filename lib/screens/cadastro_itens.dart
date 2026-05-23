import 'package:flutter/material.dart';

class CadastroItensPage extends StatefulWidget {
  const CadastroItensPage({super.key});

  @override
  State<CadastroItensPage> createState() => _CadastroItensPageState();
}

class _CadastroItensPageState extends State<CadastroItensPage> {

  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final userIdController = TextEditingController();
  final imagemController = TextEditingController(); // por enquanto URL

  bool isLoading = false;

  void cadastrarItem() {
    print(nomeController.text);
    print(descricaoController.text);
    print(userIdController.text);
    print(imagemController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item cadastrado (simulado)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      appBar: AppBar(
        title: const Text("Cadastrar Item"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(Icons.inventory, size: 60, color: Colors.blue),

                const SizedBox(height: 10),

                const Text(
                  "Novo Item",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 20),

                // NOME DO ITEM
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome do Item",
                    prefixIcon: const Icon(Icons.label, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // DESCRIÇÃO
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(
                    labelText: "Descrição",
                    prefixIcon: const Icon(Icons.description, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 15),

                // ID DO USUÁRIO
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    labelText: "ID do Usuário",
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 15),

                // IMAGEM (URL POR ENQUANTO)
                TextField(
                  controller: imagemController,
                  decoration: InputDecoration(
                    labelText: "URL da Imagem",
                    prefixIcon: const Icon(Icons.image, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÃO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading ? null : cadastrarItem,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Cadastrar Item"),
                  ),
                ),

                const SizedBox(height: 10),

                // VOLTAR
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Voltar",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}