import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/sale_card.dart';

// ============================================================
// SALES tab
// ============================================================
class SalesTab extends StatefulWidget {
  const SalesTab({super.key});
  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.I,
      builder: (context, _) {
        final s = Store.I;
        final list = s.sales
            .where((x) => q.isEmpty || x.name.contains(q) || x.buyerName.contains(q) || x.buyerMobile.contains(q))
            .toList()
          ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

        final suggestions = s.sales
            .map((x) => [x.name, if (x.buyerName.isNotEmpty) x.buyerName, if (x.buyerMobile.isNotEmpty) x.buyerMobile])
            .expand((x) => x)
            .toSet()
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            SearchBox(
              hint: 'পণ্য / ক্রেতার নাম বা মোবাইল...',
              onChanged: (v) => setState(() => q = v),
              suggestions: suggestions,
            ),
            const SizedBox(height: 14),
            if (list.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child:
                      Center(child: Text('কোনো বিক্রয় পাওয়া যায়নি', style: TextStyle(color: kMute, fontSize: 14))))
            else
              ...list.map((x) => Padding(padding: const EdgeInsets.only(bottom: 11), child: SaleCard(x))),
          ],
        );
      },
    );
  }
}
