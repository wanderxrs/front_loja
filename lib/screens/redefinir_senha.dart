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

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

  Future<void> redefinirSenha() async {
    String novaSenha = senhaController.text;

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
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Nova Senha"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(Icons.lock_reset, size: 60, color: primaryColor),

              const SizedBox(height: 15),

              Text(
                "Digite sua nova senha",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: senhaController,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Nova senha",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
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
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Salvar nova senha",
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
}