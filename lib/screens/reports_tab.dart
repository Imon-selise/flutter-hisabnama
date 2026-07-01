import 'dart:math';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';
import '../widgets/shared_widgets.dart';

// ============================================================
// REPORTS tab
// ============================================================
class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});
  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  late DateTime start;
  late DateTime end;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    start = DateTime(now.year, now.month, 1);
    end = now;
  }

  bool _inRange(String iso) {
    final t = DateTime.parse(iso);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return !t.isBefore(s) && !t.isAfter(e);
  }

  Future<void> _pick(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? start : end,
      firstDate: DateTime(2018),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => isStart ? start = d : end = d);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.I,
      builder: (context, _) {
        final s = Store.I;
        final rSales = s.sales.where((x) => _inRange(x.date)).toList();
        final rAdds = s.additions.where((a) => _inRange(a.date) && s.byId(a.productId) != null).toList();
        final qtyAdded = rAdds.fold(0.0, (a, x) => a + x.qty);
        final qtySold = rSales.fold(0.0, (a, x) => a + x.qty);
        final revenue = rSales.fold(0.0, (a, x) => a + x.qty * x.price);
        final cogs = rSales.fold(0.0, (a, x) => a + x.qty * x.cost);
        final profit = revenue - cogs;
        final pos = profit >= 0;

        // breakdown
        final map = <String, List<double>>{}; // [qty, rev, profit]
        final names = <String, String>{};
        for (final x in rSales) {
          map.putIfAbsent(x.productId, () => [0, 0, 0]);
          names[x.productId] = x.name;
          map[x.productId]![0] += x.qty;
          map[x.productId]![1] += x.qty * x.price;
          map[x.productId]![2] += (x.price - x.cost) * x.qty;
        }
        final breakdown = map.entries.toList()..sort((a, b) => b.value[1].compareTo(a.value[1]));

        final cards = [
          ['মোট পণ্য', '${bn(numStr(qtyAdded))} টি'],
          ['মোট বিক্রিত পণ্য', '${bn(numStr(qtySold))} টি'],
          ['মোট আয়', taka(revenue)],
          ['বিক্রিত পণ্যের খরচ', taka(cogs)],
          ['অবশিষ্ট স্টক মূল্য', taka(s.totalStockValue)],
          ['লেনদেন', '${bn(rSales.length)} টি'],
        ];

        final barMax = max(1.0, [revenue, cogs, profit.abs()].reduce(max));

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            // date range
            Container(
              decoration: cardDeco,
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(child: _dateBtn('শুরুর তারিখ', start, () => _pick(true))),
                const SizedBox(width: 10),
                Expanded(child: _dateBtn('শেষ তারিখ', end, () => _pick(false))),
              ]),
            ),
            const SizedBox(height: 13),
            // hero
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: pos ? const [Color(0xFF3FCB87), kGreen] : const [Color(0xFFF0686C), kRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: (pos ? kGreen : kRed).withOpacity(.28), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pos ? 'মোট লাভ' : 'মোট ক্ষতি',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.85), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('${pos ? '' : '−'}${taka(profit.abs())}',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 3),
                Text('আয় ${taka(revenue)} − খরচ ${taka(cogs)}',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.8))),
              ]),
            ),
            const SizedBox(height: 13),
            // result cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 2.1,
              children: cards
                  .map((c) => Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0F5A46B4), blurRadius: 10, offset: Offset(0, 2))
                            ]),
                        padding: const EdgeInsets.all(13),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(c[0],
                                  style: const TextStyle(fontSize: 11.5, color: kMute, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(c[1],
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kInk))),
                            ]),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 13),
            // bar chart
            Container(
              decoration: cardDeco,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('আয় · খরচ · লাভ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kInk)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar('আয়', revenue, barMax, kHeaderGradient),
                      _bar('খরচ', cogs, barMax, const LinearGradient(colors: [Color(0xFFF0A04B), kOrange])),
                      _bar(
                          'লাভ',
                          profit.abs(),
                          barMax,
                          LinearGradient(
                              colors: pos ? const [Color(0xFF3FCB87), kGreen] : const [Color(0xFFF0686C), kRed])),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text('পণ্যভিত্তিক হিসাব',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kInk))),
            if (rSales.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child:
                      Center(child: Text('এই সময়ে কোনো বিক্রয় নেই', style: TextStyle(color: kMute, fontSize: 13.5))))
            else
              ...breakdown.map((e) {
                final qtyV = e.value[0], revV = e.value[1], profV = e.value[2];
                final p = profV >= 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Color(0x0F5A46B4), blurRadius: 10, offset: Offset(0, 2))]),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(names[e.key] ?? '',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kInk)),
                        const SizedBox(height: 2),
                        Text('বিক্রি ${bn(numStr(qtyV))} · আয় ${taka(revV)}',
                            style: const TextStyle(fontSize: 11.5, color: kMute)),
                      ]),
                      Text('${p ? '+' : '−'}${taka(profV.abs())}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p ? kGreen : kRed)),
                    ]),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _bar(String label, double value, double maxV, Gradient grad) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(taka(value), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kSubInk)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: max(6, value / maxV * 96),
                decoration: BoxDecoration(
                    gradient: grad,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7), bottom: Radius.circular(3))),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11.5, color: kMute, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );

  Widget _dateBtn(String label, DateTime d, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 5),
              child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: kMute))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFF6F4FC),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFECE8F7))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(fmtDate(d), style: const TextStyle(fontSize: 13.5, color: kInk)),
              const Icon(Icons.calendar_today_outlined, size: 15, color: kMute),
            ]),
          ),
        ]),
      );
}
