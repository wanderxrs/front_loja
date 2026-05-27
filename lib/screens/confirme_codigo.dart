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

  final Color primaryColor = const Color(0xFFFF6A00);
  final Color backgroundColor = const Color(0xFF0D0D0D);
  final Color cardColor = const Color(0xFF1A1A1A);
  final Color textColor = const Color(0xFFF5F5F5);

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
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Confirmar Código"),
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

              Icon(Icons.lock, size: 60, color: primaryColor),

              const SizedBox(height: 15),

              Text(
                "Digite o código que você recebeu no email",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Código",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.confirmation_number, color: primaryColor),
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
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Confirmar",
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