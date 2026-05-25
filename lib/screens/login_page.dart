import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'cadastro_page.dart';
import 'home_page.dart';
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

  Future<void> fazerLogin() async {
    setState(() => isLoading = true);

    final api = ServicoApi();
    var resultado = await api.login(emailController.text, senhaController.text);

    setState(() => isLoading = false);

    if (resultado != null && resultado.containsKey('user')) {
      // ACESSO CORRETO AOS DADOS DENTRO DE 'user'
      final Map<String, dynamic> userData = resultado['user'];
      
      final rawId = userData['id'];
      final rawType = userData['user_type'];

      int idUsuarioLogado = (rawId is int) ? rawId : int.tryParse(rawId.toString()) ?? 0;
      final String tipoUsuario = rawType != null ? rawType.toString().toLowerCase() : '';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login realizado com sucesso!")),
      );

      if (tipoUsuario == 'vendedor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VendedorHomePage(idVendedor: idUsuarioLogado)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(idUsuario: idUsuarioLogado)),
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
    // ... (o seu build permanece igual)
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: const Text("Login"), backgroundColor: Colors.blue, foregroundColor: Colors.white, centerTitle: true),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email, color: Colors.blue), border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: senhaController, obscureText: true, decoration: const InputDecoration(labelText: "Senha", prefixIcon: Icon(Icons.lock, color: Colors.blue), border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: isLoading ? null : fazerLogin,
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroPage())), child: const Text("Cadastre-se")),
            ],
          ),
        ),
      ),
    );
  }
}