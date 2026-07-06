import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/product.dart';
import '../store/store.dart';
import 'shared_widgets.dart';

class ProductDetailSheet extends StatefulWidget {
  final String productId;
  final void Function(String) onSell;
  const ProductDetailSheet({super.key, required this.productId, required this.onSell});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  @override
  void initState() {
    super.initState();
    Store.I.addListener(_onChanged);
  }

  @override
  void dispose() {
    Store.I.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final s = Store.I;
    final p = s.byId(widget.productId);
    if (p == null) return const SizedBox.shrink();
    final added = s.additions.where((a) => a.productId == p.id).fold(0.0, (a, x) => a + x.qty);
    final sold = s.sales.where((x) => x.productId == p.id).fold(0.0, (a, x) => a + x.qty);

    return Container(
      decoration: const BoxDecoration(color: kBg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(top: 6, bottom: 16),
                    decoration: BoxDecoration(color: const Color(0xFFD8D2EA), borderRadius: BorderRadius.circular(3)))),
            Row(children: [
              avatar(p.name, p.tintI, size: 58, radius: 16, font: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kInk)),
                  const SizedBox(height: 2),
                  Text('যোগ হয়েছে  ${fmtDate(DateTime.parse(p.date))}',
                      style: const TextStyle(fontSize: 12.5, color: kMute)),
                ]),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: kInk, size: 22),
                tooltip: 'এডিট',
                onPressed: () => _showEditDialog(context, p),
              ),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              _statBox('বর্তমান স্টক', '${bn(numStr(p.qty))} ${p.unit}', kPrimary),
              const SizedBox(width: 11),
              _statBox('স্টক মূল্য', taka(p.qty * p.cost), kInk),
            ]),
            const SizedBox(height: 11),
            Row(children: [
              _statBox('মোট যোগ', '${bn(numStr(added))} ${p.unit}', kInk, big: false),
              const SizedBox(width: 11),
              _statBox('মোট বিক্রি', '${bn(numStr(sold))} ${p.unit}', kInk, big: false),
            ]),
            const SizedBox(height: 11),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                _row('ক্রয় মূল্য', taka(p.cost), border: true),
                _row('বিক্রয় মূল্য', taka(p.price), border: true),
                if (p.supplierName.isNotEmpty || p.supplierMobile.isNotEmpty) ...[
                  _row(
                      'সরবরাহকারী',
                      [
                        if (p.supplierName.isNotEmpty) p.supplierName,
                        if (p.supplierMobile.isNotEmpty) fmtPhone(p.supplierMobile)
                      ].join(' · ')),
                ],
              ]),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    if (!requireLogin(context)) return;
                    Store.I.deleteProduct(p.id);
                    showToast(context, 'পণ্য মুছে ফেলা হয়েছে', kOrange);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, color: kRed, size: 18),
                  label: const Text('মুছে ফেলুন',
                      style: TextStyle(color: kRed, fontWeight: FontWeight.w700, fontSize: 15)),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFDECEC),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSell(p.id);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(gradient: kHeaderGradient, borderRadius: BorderRadius.circular(14)),
                    child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: const Text('বিক্রয় করুন',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color, {bool big = true}) => Expanded(
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: kMute)),
            const SizedBox(height: 3),
            FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child:
                    Text(value, style: TextStyle(fontSize: big ? 20 : 18, fontWeight: FontWeight.w700, color: color))),
          ]),
        ),
      );

  Widget _row(String l, String v, {bool border = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: border ? const Border(bottom: BorderSide(color: Color(0xFFF1EEF8))) : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: const TextStyle(fontSize: 14, color: Color(0xFF6A6580))),
          Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kInk)),
        ]),
      );
}

// ============================================================
// Edit product dialog (no login required)
// ============================================================
void _showEditDialog(BuildContext context, Product p) {
  final nameCtrl = TextEditingController(text: p.name);
  final qtyCtrl =
      TextEditingController(text: p.qty == p.qty.roundToDouble() ? p.qty.round().toString() : p.qty.toString());
  final costCtrl =
      TextEditingController(text: p.cost == p.cost.roundToDouble() ? p.cost.round().toString() : p.cost.toString());
  final priceCtrl =
      TextEditingController(text: p.price == p.price.roundToDouble() ? p.price.round().toString() : p.price.toString());
  final supplierNameCtrl = TextEditingController(text: p.supplierName);
  final supplierMobileCtrl =
      TextEditingController(text: p.supplierMobile.isNotEmpty ? fmtPhone(p.supplierMobile) : '+88');
  String unit = p.unit;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setDState) {
        return Container(
          decoration: const BoxDecoration(color: kBg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 26),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(top: 6, bottom: 16),
                        decoration:
                            BoxDecoration(color: const Color(0xFFD8D2EA), borderRadius: BorderRadius.circular(3)))),
                const Text('পণ্য এডিট করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kInk)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'নাম', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'পরিমাণ', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: unit,
                      items: ['কেজি', 'লিটার', 'পিস', 'মিটার', 'বস্তা', 'প্যাকেট']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setDState(() => unit = v!),
                      decoration: const InputDecoration(labelText: 'একক', border: OutlineInputBorder()),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: costCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ক্রয় মূল্য', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'বিক্রয় মূল্য', border: OutlineInputBorder()),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 6),
                        child: Text('সরবরাহকারীর নাম',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF6A6580))),
                      ),
                      SuggestTextField(
                          controller: supplierNameCtrl,
                          hint: 'নাম দিন',
                          suggestions: Store.I.products
                              .map((p) => p.supplierName.trim())
                              .where((n) => n.isNotEmpty)
                              .toSet()
                              .toList()),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 6),
                        child: Text('সরবরাহকারীর মোবাইল',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF6A6580))),
                      ),
                      SuggestTextField(
                          controller: supplierMobileCtrl,
                          hint: 'মোবাইল নম্বর',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneFormatter()],
                          suggestions: Store.I.products
                              .map((p) => rawPhone(p.supplierMobile))
                              .where((n) => n.isNotEmpty && n != '+88')
                              .map((n) => fmtPhone(n))
                              .toSet()
                              .toList()),
                    ]),
                  ),
                ]),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) {
                        showToast(ctx, 'পণ্যের নাম দিন', kOrange);
                        return;
                      }
                      Store.I.updateProduct(
                        p.id,
                        nameCtrl.text.trim(),
                        double.tryParse(qtyCtrl.text) ?? 0,
                        unit,
                        double.tryParse(costCtrl.text) ?? 0,
                        double.tryParse(priceCtrl.text) ?? 0,
                        supplierName: supplierNameCtrl.text.trim(),
                        supplierMobile: rawPhone(supplierMobileCtrl.text.trim()),
                      );
                      Navigator.pop(ctx);
                      showToast(context, 'পণ্য আপডেট হয়েছে', kGreen);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('সেভ করুন', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
