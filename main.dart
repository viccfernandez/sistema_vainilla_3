import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const VainillaApp());

// ---------- Colores ----------
const cream = Color(0xFFFFF6E5);
const vanilla = Color(0xFFF3E1B5);
const rose = Color(0xFFE8A0B4);
const roseLight = Color(0xFFFBE3EA);
const cocoa = Color(0xFF6B4A3A);

// ---------- Datos ----------
class Product {
  final String name;
  final String category;
  final int price;
  final Color color;
  final IconData icon;
  const Product(this.name, this.category, this.price, this.color, this.icon);
}

const products = <Product>[
  Product('Vestido floral', 'Vestidos', 189000, Color(0xFFFBE3EA), Icons.checkroom),
  Product('Vestido lino', 'Vestidos', 220000, Color(0xFFF3E1B5), Icons.checkroom),
  Product('Blusa vainilla', 'Blusas', 95000, Color(0xFFFFF0C9), Icons.dry_cleaning),
  Product('Blusa encaje', 'Blusas', 110000, Color(0xFFF6D6E0), Icons.dry_cleaning),
  Product('Jean mom', 'Pantalones', 150000, Color(0xFFDCE8F5), Icons.straighten),
  Product('Pantalón crema', 'Pantalones', 140000, Color(0xFFF3E1B5), Icons.straighten),
  Product('Bolso mini', 'Accesorios', 85000, Color(0xFFFBE3EA), Icons.shopping_bag),
  Product('Scrunchie seda', 'Accesorios', 25000, Color(0xFFFFF0C9), Icons.favorite),
];

const categories = ['Todo', 'Vestidos', 'Blusas', 'Pantalones', 'Accesorios'];

final cart = ValueNotifier<List<Product>>([]);

String gs(int n) =>
    'Gs. ${n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';

// ---------- App ----------
class VainillaApp extends StatelessWidget {
  const VainillaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vainilla Clothes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: rose, surface: cream),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: cocoa,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ---------- Logo: flor de lirio ----------
class LilyLogo extends StatelessWidget {
  final double size;
  const LilyLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _LilyPainter());
}

class _LilyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    canvas.translate(r, r);

    Path petal(double len, double w) => Path()
      ..moveTo(0, 0)
      ..cubicTo(-w, -len * 0.35, -w * 0.7, -len * 0.85, 0, -len)
      ..cubicTo(w * 0.7, -len * 0.85, w, -len * 0.35, 0, 0);

    // 6 pétalos: 3 de atrás (más rosados) y 3 de adelante (claros)
    for (var i = 0; i < 6; i++) {
      final back = i.isEven;
      canvas.save();
      canvas.rotate(i * math.pi / 3 + (back ? 0 : 0));
      final len = r * (back ? 0.95 : 0.85);
      final w = r * (back ? 0.42 : 0.36);
      final p = petal(len, w);
      canvas.drawPath(p, Paint()..color = back ? rose : roseLight);
      canvas.drawPath(
        p,
        Paint()
          ..color = cocoa.withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.03,
      );
      // nervadura central
      canvas.drawLine(
        Offset.zero,
        Offset(0, -len * 0.7),
        Paint()
          ..color = rose.withAlpha(150)
          ..strokeWidth = r * 0.03
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    // estambres
    final stem = Paint()
      ..color = const Color(0xFFC9A24B)
      ..strokeWidth = r * 0.04
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + math.pi / 6;
      final end = Offset(math.cos(a), math.sin(a)) * r * 0.32;
      canvas.drawLine(Offset.zero, end, stem);
      canvas.drawCircle(end, r * 0.05, Paint()..color = cocoa);
    }
    canvas.drawCircle(Offset.zero, r * 0.06, Paint()..color = const Color(0xFFC9A24B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------- Home ----------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selected = 'Todo';

  @override
  Widget build(BuildContext context) {
    final list = selected == 'Todo'
        ? products
        : products.where((p) => p.category == selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LilyLogo(size: 34),
            const SizedBox(width: 8),
            Text('Vainilla Clothes',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: cocoa, fontSize: 20)),
          ],
        ),
        actions: [
          ValueListenableBuilder<List<Product>>(
            valueListenable: cart,
            builder: (_, items, __) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Badge(
                  isLabelVisible: items.isNotEmpty,
                  label: Text('${items.length}'),
                  backgroundColor: rose,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartPage())),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: vanilla,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nueva colección',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: cocoa)),
                      SizedBox(height: 4),
                      Text('Ropa suave y dulce para todos los días',
                          style: TextStyle(color: cocoa)),
                    ],
                  ),
                ),
                const LilyLogo(size: 64),
              ],
            ),
          ),
          // Categorías
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = categories[i];
                return ChoiceChip(
                  label: Text(c),
                  selected: selected == c,
                  selectedColor: rose,
                  backgroundColor: Colors.white,
                  labelStyle:
                      TextStyle(color: selected == c ? Colors.white : cocoa),
                  side: BorderSide.none,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => selected = c),
                );
              },
            ),
          ),
          // Productos
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => ProductCard(product: list[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: cream,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (_) => ProductSheet(product: product),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: product.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                    child: Icon(product.icon, size: 56, color: cocoa)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: cocoa)),
                  const SizedBox(height: 2),
                  Text(gs(product.price),
                      style: const TextStyle(color: rose, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSheet extends StatelessWidget {
  final Product product;
  const ProductSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
                color: product.color, borderRadius: BorderRadius.circular(20)),
            child: Icon(product.icon, size: 80, color: cocoa),
          ),
          const SizedBox(height: 16),
          Text(product.name,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: cocoa)),
          Text(product.category, style: const TextStyle(color: cocoa)),
          const SizedBox(height: 8),
          Text(gs(product.price),
              style: const TextStyle(
                  fontSize: 20, color: rose, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: rose,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Agregar al carrito'),
              onPressed: () {
                cart.value = [...cart.value, product];
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${product.name} agregado 🌸'),
                      backgroundColor: cocoa),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Carrito ----------
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi carrito')),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: cart,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LilyLogo(size: 80),
                  SizedBox(height: 12),
                  Text('Tu carrito está vacío', style: TextStyle(color: cocoa)),
                ],
              ),
            );
          }
          final total = items.fold<int>(0, (s, p) => s + p.price);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final p = items[i];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: p.color,
                            child: Icon(p.icon, color: cocoa)),
                        title: Text(p.name,
                            style: const TextStyle(color: cocoa)),
                        subtitle: Text(gs(p.price)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: rose),
                          onPressed: () {
                            final l = [...cart.value]..removeAt(i);
                            cart.value = l;
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: vanilla,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontSize: 18, color: cocoa)),
                        Text(gs(total),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: cocoa)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: rose,
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () {
                          cart.value = [];
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('¡Gracias por tu pedido! 🌸'),
                                backgroundColor: cocoa),
                          );
                        },
                        child: const Text('Hacer pedido'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
