import 'package:flutter/material.dart';
import '../services/api_connect.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool queroSerVendedor = false;
  bool isLoading = false;

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

  Future<void> cadastrar() async {
    if (!emailController.text.endsWith("@gmail.com")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O e-mail precisa terminar com @gmail.com"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final api = ServicoApi();

    var sucesso = await api.cadastrarUsuario(
      nomeController.text,
      emailController.text,
      senhaController.text,
      queroSerVendedor ? "vendedor" : "cliente",
    );

    setState(() {
      isLoading = false;
    });

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar usuário")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Cadastro"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
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
              Icon(Icons.person_add, size: 60, color: primaryColor),
              const SizedBox(height: 10),

              Text(
                "Criar Conta",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 20),

              // NOME
              TextField(
                controller: nomeController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.person, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // EMAIL
              TextField(
                controller: emailController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "E-mail",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.email, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // SENHA
              TextField(
                controller: senhaController,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Senha",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // BOTÃO SIM/NÃO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quero ser vendedor?",
                    style: TextStyle(color: textColor),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: queroSerVendedor
                          ? primaryColor
                          : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        queroSerVendedor = !queroSerVendedor;
                      });
                    },
                    child: Text(queroSerVendedor ? "SIM" : "NÃO"),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // BOTÃO CADASTRAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: isLoading ? null : cadastrar,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Cadastrar",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // VOLTAR LOGIN
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Voltar para o login",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
