import 'package:flutter/material.dart';

// =============================================================
// MODEL
// =============================================================
class Item {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final String emoji;

  const Item({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.emoji,
  });

  /// Simula o mapeamento de uma linha do banco de dados.
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      preco: (map['preco'] as num).toDouble(),
      emoji: map['emoji'] as String,
    );
  }
}

// =============================================================
// SERVIÇO — substitua pelo seu acesso real ao banco de dados
// (sqflite, supabase, http, etc.)
// =============================================================
class ItemService {
  /// Retorna os itens do banco de dados.
  /// Troque o corpo deste método pela sua query real.
  Future<List<Item>> fetchItens() async {
    // Simula latência de rede / banco
    await Future.delayed(const Duration(milliseconds: 800));

    // ↓↓↓ Substitua pelo resultado real da sua query ↓↓↓
    final rows = [
      {'id': 1, 'nome': 'Tênis Runner Pro', 'descricao': 'Conforto extremo para longas corridas.', 'preco': 299.90, 'emoji': '👟'},
      {'id': 2, 'nome': 'Mochila Urbana', 'descricao': 'Compartimentos inteligentes e resistente à água.', 'preco': 189.00, 'emoji': '🎒'},
      {'id': 3, 'nome': 'Fone Bluetooth', 'descricao': 'Cancelamento de ruído ativo e 30 h de bateria.', 'preco': 459.99, 'emoji': '🎧'},
      {'id': 4, 'nome': 'Câmera Instant', 'descricao': 'Foto revelada em segundos, estilo vintage.', 'preco': 349.00, 'emoji': '📷'},
      {'id': 5, 'nome': 'Relógio Smartwatch', 'descricao': 'Monitor cardíaco, GPS e resistência à água.', 'preco': 699.00, 'emoji': '⌚'},
      {'id': 6, 'nome': 'Luminária LED', 'descricao': 'Luz quente regulável para home office.', 'preco': 129.90, 'emoji': '💡'},
    ];

    return rows.map(Item.fromMap).toList();
  }
}

// =============================================================
// PÁGINA PRINCIPAL
// =============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ItemService _service = ItemService();
  late Future<List<Item>> _futureItens;

  @override
  void initState() {
    super.initState();
    _futureItens = _service.fetchItens();
  }

  void _mostrarPopupCompra(BuildContext context, Item item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => _DialogCompra(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E0C),
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Item>>(
        future: _futureItens,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8C96D)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar itens:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8A8780)),
              ),
            );
          }
          final itens = snapshot.data ?? [];
          if (itens.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum item encontrado.',
                style: TextStyle(color: Color(0xFF8A8780)),
              ),
            );
          }
          return _buildLista(itens);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F0E0C),
      elevation: 0,
      centerTitle: false,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          children: [
            TextSpan(text: 'MY', style: TextStyle(color: Color(0xFFE8C96D))),
            TextSpan(text: 'STORE', style: TextStyle(color: Color(0xFFF0EDE6))),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFF2E2D29), height: 1),
      ),
    );
  }

  Widget _buildLista(List<Item> itens) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: itens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = itens[index];
        return _ItemCard(
          item: item,
          onComprar: () => _mostrarPopupCompra(context, item),
        );
      },
    );
  }
}

// =============================================================
// CARD DO ITEM
// =============================================================
class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onComprar;

  const _ItemCard({required this.item, required this.onComprar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2D29)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone / imagem do produto
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1916),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E2D29)),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 14),

            // Nome, descrição e preço
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: const TextStyle(
                      color: Color(0xFFF0EDE6),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.descricao,
                    style: const TextStyle(
                      color: Color(0xFF8A8780),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'R\$ ${item.preco.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFE8C96D),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Botão Comprar
            ElevatedButton(
              onPressed: onComprar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8C96D),
                foregroundColor: const Color(0xFF0F0E0C),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// POPUP DE COMPRA
// =============================================================
class _DialogCompra extends StatelessWidget {
  final Item item;

  const _DialogCompra({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF201F1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji grande
            Text(item.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 16),

            // Título
            const Text(
              'Comprar item',
              style: TextStyle(
                color: Color(0xFFF0EDE6),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            // Nome do item
            Text(
              item.nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8A8780),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),

            // Preço
            Text(
              'R\$ ${item.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFE8C96D),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),

            // Botão Comprar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: chamar lógica de compra real aqui
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ "${item.nome}" comprado com sucesso!'),
                      backgroundColor: const Color(0xFF2E2D29),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8C96D),
                  foregroundColor: const Color(0xFF0F0E0C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Comprar'),
              ),
            ),
            const SizedBox(height: 12),

            // Cancelar
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF8A8780), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// ENTRY POINT (remova se já tiver um main.dart)
// =============================================================
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    ),
  );
}