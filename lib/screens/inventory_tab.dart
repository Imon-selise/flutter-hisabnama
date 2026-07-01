import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_sheet.dart';

// ============================================================
// INVENTORY tab
// ============================================================
class InventoryTab extends StatefulWidget {
  final void Function(String productId) onSell;
  const InventoryTab({super.key, required this.onSell});
  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final s = Store.I;
    final list = s.products.where((p) => q.isEmpty || p.name.contains(q)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        SearchBox(hint: 'পণ্য খুঁজুন...', onChanged: (v) => setState(() => q = v)),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('মোট পণ্য সংখ্যা: ${bn(s.products.length)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kInk)),
              Text('স্টক মূল্য ${taka(s.totalStockValue)}',
                  style: const TextStyle(fontSize: 12.5, color: kMute, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: Text('কোনো পণ্য পাওয়া যায়নি', style: TextStyle(color: kMute, fontSize: 14))))
        else
          ...list.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: ProductCard(p, onTap: () => _openDetail(p.id)),
              )),
      ],
    );
  }

  void _openDetail(String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProductDetailSheet(productId: id, onSell: widget.onSell),
    );
  }
}
