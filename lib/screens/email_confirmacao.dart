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

  // 🎨 CORES
  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

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
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Recuperar Senha"),
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

              Icon(Icons.email, size: 60, color: primaryColor),

              const SizedBox(height: 15),

              Text(
                "Vamos mandar um email para você com o código de confirmação",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 20),

              // EMAIL
              TextField(
                controller: emailController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Digite seu e-mail",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.email, color: primaryColor),
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
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Enviar",
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