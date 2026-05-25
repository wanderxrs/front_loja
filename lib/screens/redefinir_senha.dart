import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'login_page.dart';

class RedefinirSenhaPage extends StatefulWidget {
  final String email;

  const RedefinirSenhaPage({super.key, required this.email});

  @override
  State<RedefinirSenhaPage> createState() => _RedefinirSenhaPageState();
}

class _RedefinirSenhaPageState extends State<RedefinirSenhaPage> {

  final senhaController = TextEditingController();
  bool isLoading = false;

  Future<void> redefinirSenha() async {
    String novaSenha = senhaController.text;

    // 🔥 DEBUG (ESSENCIAL)
    print("EMAIL RECEBIDO: ${widget.email}");
    print("NOVA SENHA: $novaSenha");

    if (novaSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite a nova senha")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final api = ServicoApi();

    bool sucesso = await api.redefinirSenha(
      widget.email,
      novaSenha,
    );

    setState(() {
      isLoading = false;
    });

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Senha redefinida com sucesso!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao redefinir senha")),
      );
    }
  }

  @override
  void dispose() {
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      appBar: AppBar(
        title: const Text("Nova Senha"),
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

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Icon(Icons.lock_reset, size: 60, color: Colors.blue),

              const SizedBox(height: 15),

              const Text(
                "Digite sua nova senha",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Nova senha",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : redefinirSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Salvar nova senha"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}