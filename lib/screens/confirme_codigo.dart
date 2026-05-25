import 'package:flutter/material.dart';
import '../services/api_connect.dart';
import 'redefinir_senha.dart';

class ConfirmarCodigoLogin extends StatefulWidget {
  final String email;

  const ConfirmarCodigoLogin({super.key, required this.email});

  @override
  State<ConfirmarCodigoLogin> createState() => _ConfirmarCodigoLoginState();
}

class _ConfirmarCodigoLoginState extends State<ConfirmarCodigoLogin> {

  final codigoController = TextEditingController();
  bool isLoading = false;

  Future<void> verificarCodigo() async {
    String codigo = codigoController.text;

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite o código")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final api = ServicoApi();

    bool valido = await api.verificarCodigo(codigo);

    setState(() {
      isLoading = false;
    });

    if (valido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código correto!")),
      );

      // 🔥 AGORA VAI PRA REDEFINIR SENHA
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RedefinirSenhaPage(
            email: widget.email,
          ),
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código inválido")),
      );
    }
  }

  @override
  void dispose() {
    codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      appBar: AppBar(
        title: const Text("Confirmar Código"),
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

              const Icon(Icons.lock, size: 60, color: Colors.blue),

              const SizedBox(height: 15),

              const Text(
                "Digite o código que você recebeu no email",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Código",
                  prefixIcon: const Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verificarCodigo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirmar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}