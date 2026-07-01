import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';
import 'shared_widgets.dart';

class SaleCard extends StatelessWidget {
  final dynamic s;
  const SaleCard(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = Store.I.byId(s.productId);
    final tintI = p?.tintI ?? 4;
    final total = s.qty * s.price;
    final profit = (s.price - s.cost) * s.qty;
    final pos = profit >= 0;

    return Container(
      decoration: cardDeco,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              avatar(s.name, tintI, size: 42, radius: 12, font: 18),
              const SizedBox(width: 11),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: kInk)),
                  const SizedBox(height: 2),
                  Text(fmtDate(DateTime.parse(s.date)),
                      style: const TextStyle(fontSize: 11.5, color: kMute, fontWeight: FontWeight.w500)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(taka(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kInk)),
                Text('${pos ? 'লাভ ' : 'ক্ষতি '}${taka(profit.abs())}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pos ? kGreen : kRed)),
              ]),
              const SizedBox(width: 6),
              InkWell(
                onTap: () async {
                  if (!requireLogin(context)) return;
                  await Store.I.deleteSale(s.id);
                  if (context.mounted) {
                    showToast(context, 'বিক্রয় ডেটা মুছে ফেলা হয়েছে', kOrange);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: kRed, size: 18),
                ),
              ),
            ],
          ),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 11), child: Divider(height: 1, color: Color(0xFFF1EEF8))),
          Row(children: [
            _col('পরিমাণ', bn(numStr(s.qty))),
            _divider(),
            _col('একক মূল্য', taka(s.price)),
            _divider(),
            _col('মোট', taka(total)),
          ]),
        ],
      ),
    );
  }

  Widget _col(String l, String v) => Expanded(
        child: Column(children: [
          Text(l, style: const TextStyle(fontSize: 10.5, color: Color(0xFFA7A2BC))),
          const SizedBox(height: 2),
          Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kSubInk)),
        ]),
      );
  Widget _divider() => Container(width: 1, height: 28, color: const Color(0xFFF1EEF8));
}
