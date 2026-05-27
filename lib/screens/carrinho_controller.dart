class CarrinhoController {
  static final CarrinhoController _instance = CarrinhoController._internal();

  factory CarrinhoController() => _instance;

  CarrinhoController._internal();

  List<Map<String, dynamic>> itens = [];

  void adicionarItem(Map<String, dynamic> produto, int quantidade) {
    final index = itens.indexWhere((i) => i['id'] == produto['id']);

    if (index >= 0) {
      itens[index]['quantidade'] += quantidade;
    } else {
      itens.add({
        'id': produto['id'],
        'nome': produto['name'],
        'preco': double.parse(produto['price'].toString()),
        'quantidade': quantidade,
      });
    }
  }


  void diminuirQuantidade(int index) {
    if (itens[index]['quantidade'] > 1) {
      itens[index]['quantidade']--;
    } else {
      itens.removeAt(index);
    }
  }

 
  void aumentarQuantidade(int index) {
    itens[index]['quantidade']++;
  }


  void removerItem(int index) {
    itens.removeAt(index);
  }

  double get total {
    double soma = 0;
    for (var item in itens) {
      soma += item['preco'] * item['quantidade'];
    }
    return soma;
  }
}