import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'cadastro_page.dart';
import 'home_page.dart';
import 'email_confirmacao.dart';
import 'vendedor_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> { 
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool isLoading = false;

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

  Future<void> fazerLogin() async {
    setState(() => isLoading = true);

    final api = ServicoApi();
    var resultado = await api.login(
      emailController.text,
      senhaController.text,
    );

    setState(() => isLoading = false);

    if (resultado != null && resultado.containsKey('user')) {
      final Map<String, dynamic> userData = resultado['user'];

      final rawId = userData['id'];
      final rawType = userData['user_type'];

      int idUsuarioLogado =
          (rawId is int) ? rawId : int.tryParse(rawId.toString()) ?? 0;

      final String tipoUsuario =
          rawType != null ? rawType.toString().toLowerCase() : '';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login realizado com sucesso!")),
      );

      if (tipoUsuario == 'vendedor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VendedorHomePage(idVendedor: idUsuarioLogado),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(idUsuario: idUsuarioLogado),
          ),
        );
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email ou senha inválidos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("MARKETX"),
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
              Text(
                "MARKETX",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Bem vindo!",
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 25),

              Icon(Icons.person, size: 60, color: primaryColor),

              const SizedBox(height: 20),

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

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EmailConfirmacaoPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Esqueceu sua senha?",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: isLoading ? null : fazerLogin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastroPage(),
                  ),
                ),
                child: Text(
                  "Criar conta",
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