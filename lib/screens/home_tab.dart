import 'dart:math';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/summary_card.dart';

// ============================================================
// HOME tab
// ============================================================
class HomeTab extends StatelessWidget {
  final VoidCallback onAddProduct, onAddSale;
  const HomeTab({super.key, required this.onAddProduct, required this.onAddSale});

  @override
  Widget build(BuildContext context) {
    final s = Store.I;
    final now = DateTime.now();
    bool thisMonth(String iso) {
      final d = DateTime.parse(iso);
      return d.year == now.year && d.month == now.month;
    }

    final monthSales = s.sales.where((x) => thisMonth(x.date)).toList();
    final soldMonth = monthSales.fold(0.0, (a, x) => a + x.qty);
    final revMonth = monthSales.fold(0.0, (a, x) => a + x.qty * x.price);
    final profMonth = monthSales.fold(0.0, (a, x) => a + (x.price - x.cost) * x.qty);
    final lows = s.products.where((p) => p.qty <= 10).toList();

    // trend: last up-to-14 days of current month
    final today = now.day;
    final dayRev = <int, double>{};
    for (final x in monthSales) {
      final dd = DateTime.parse(x.date).day;
      dayRev[dd] = (dayRev[dd] ?? 0) + x.qty * x.price;
    }
    final days = [for (int i = max(1, today - 13); i <= today; i++) i];
    final maxRev = max(1.0, days.fold(0.0, (m, d) => max(m, dayRev[d] ?? 0)));

    final cards = [
      SummaryCard(Icons.inventory_2_outlined, 'মোট স্টক মূল্য', taka(s.totalStockValue), 5),
      SummaryCard(Icons.shopping_cart_outlined, 'এ মাসে বিক্রি', '${bn(numStr(soldMonth))} টি', 3),
      SummaryCard(Icons.account_balance_wallet_outlined, 'এ মাসের আয়', taka(revMonth), 1),
      SummaryCard(Icons.trending_up_rounded, 'এ মাসের লাভ', taka(profMonth), 0),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: cards,
        ),
        const SizedBox(height: 14),
        // trend chart
        Container(
          decoration: cardDeco,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('এ মাসের বিক্রয় ধারা',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kInk)),
                  Text(taka(revMonth),
                      style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final d in days)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: max(4, (dayRev[d] ?? 0) / maxRev * 84),
                                decoration: BoxDecoration(
                                  gradient: (dayRev[d] ?? 0) > 0 ? kHeaderGradient : null,
                                  color: (dayRev[d] ?? 0) > 0 ? null : const Color(0xFFECE8F7),
                                  borderRadius:
                                      const BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(3)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(bn(d),
                                  style: const TextStyle(
                                      fontSize: 9, color: Color(0xFFB6B1C9), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // quick actions
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onAddProduct,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4DEF8), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                            BoxDecoration(color: const Color(0xFFEEEAFD), borderRadius: BorderRadius.circular(13)),
                        child: const Icon(Icons.add, color: kPrimary, size: 22),
                      ),
                      const SizedBox(height: 8),
                      const Text('পণ্য যোগ করুন',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: kInk)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onAddSale,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: kHeaderGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x526A47E0), blurRadius: 16, offset: Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                            BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(13)),
                        child: const Icon(Icons.point_of_sale_outlined, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 8),
                      const Text('বিক্রয় করুন',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (lows.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFBE2C4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: kOrange, size: 22),
                const SizedBox(width: 11),
                Expanded(
                  child: Text('${bn(lows.length)} টি পণ্যের স্টক কমে এসেছে — শীঘ্রই পুনরায় মজুদ করুন।',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFA8631A), fontWeight: FontWeight.w500, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
