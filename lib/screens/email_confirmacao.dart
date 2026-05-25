import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'confirme_codigo.dart';

class EmailConfirmacaoPage extends StatefulWidget {
  const EmailConfirmacaoPage({super.key});

  @override
  State<EmailConfirmacaoPage> createState() => _EmailConfirmacaoPageState();
}

class _EmailConfirmacaoPageState extends State<EmailConfirmacaoPage> {

  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> enviarEmail() async {
    setState(() {
      isLoading = true;
    });

    final api = ServicoApi();

    var resposta = await api.recuperarSenha(
      emailController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (resposta != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email enviado com sucesso!")),
      );

      // 🔥 VAI PRA PRÓXIMA TELA
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmarCodigoLogin(email: emailController.text),
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao enviar email")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      appBar: AppBar(
        title: const Text("Recuperar Senha"),
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

              const Icon(Icons.email, size: 60, color: Colors.blue),

              const SizedBox(height: 15),

              const Text(
                "Vamos mandar um email para você com o código de confirmação",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // EMAIL
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Digite seu e-mail",
                  prefixIcon: const Icon(Icons.email),
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
                  onPressed: isLoading ? null : enviarEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enviar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}