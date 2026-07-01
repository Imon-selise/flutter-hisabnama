import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/product.dart';
import 'shared_widgets.dart';

class ProductCard extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  const ProductCard(this.p, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final low = p.qty <= 10;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: cardDeco,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            avatar(p.name, p.tintI),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                        child: Text(p.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kInk))),
                    if (low) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration:
                            BoxDecoration(color: const Color(0xFFFCEEDD), borderRadius: BorderRadius.circular(7)),
                        child: const Text('কম স্টক',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFD8773A))),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _miniStat('ক্রয় মূল্য', taka(p.cost), kSubInk),
                      const SizedBox(width: 14),
                      _miniStat('স্টক', '${bn(numStr(p.qty))} ${p.unit}', kSubInk),
                      const SizedBox(width: 14),
                      _miniStat('স্টক মূল্য', taka(p.qty * p.cost), kPrimary),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC9C4DA), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color valueColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFFA7A2BC), fontWeight: FontWeight.w500)),
          const SizedBox(height: 1),
          Text(value, style: TextStyle(fontSize: 13, color: valueColor, fontWeight: FontWeight.w700)),
        ],
      );
}
