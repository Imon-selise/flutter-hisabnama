import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';
import '../store/store.dart';
import '../widgets/shared_widgets.dart';

// ============================================================
// ADD tab (product / sale)
// ============================================================
class AddTab extends StatefulWidget {
  final void Function(int) onDone;
  const AddTab({super.key, required this.onDone});
  @override
  State<AddTab> createState() => AddTabState();
}

class AddTabState extends State<AddTab> {
  bool saleMode = false;
  bool get isSaleMode => saleMode;
  // product form
  final _pName = TextEditingController();
  final _pQty = TextEditingController();
  final _pCost = TextEditingController();
  final _pPrice = TextEditingController();
  final _pSupplierName = TextEditingController();
  final _pSupplierMobile = TextEditingController(text: '+88');
  String _pUnit = 'কেজি';
  DateTime _pDate = DateTime.now();
  // sale form
  String? _sProductId;
  final _sQty = TextEditingController();
  final _sPrice = TextEditingController();
  final _sBuyerName = TextEditingController();
  final _sBuyerMobile = TextEditingController(text: '+88');
  DateTime _sDate = DateTime.now();

  void setMode(bool sale, {String? productId}) {
    setState(() {
      saleMode = sale;
      if (productId != null) _sProductId = productId;
    });
  }

  @override
  void dispose() {
    _pName.dispose();
    _pQty.dispose();
    _pCost.dispose();
    _pPrice.dispose();
    _pSupplierName.dispose();
    _pSupplierMobile.dispose();
    _sQty.dispose();
    _sPrice.dispose();
    _sBuyerName.dispose();
    _sBuyerMobile.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool product) async {
    final init = product ? _pDate : _sDate;
    final d = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2018),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => product ? _pDate = d : _sDate = d);
  }

  void _submitProduct() {
    // if (!requireLogin(context)) return;
    if (_pName.text.trim().isEmpty) {
      showToast(context, 'পণ্যের নাম দিন', kOrange);
      return;
    }
    if (_pSupplierName.text.trim().isEmpty) {
      showToast(context, 'সরবরাহকারীর নাম দিন', kOrange);
      return;
    }
    if (rawPhone(_pSupplierMobile.text.trim()) == '+88') {
      showToast(context, 'সরবরাহকারীর মোবাইল নম্বর দিন', kOrange);
      return;
    }
    final qty = double.tryParse(_pQty.text) ?? 0;
    if (qty <= 0) {
      showToast(context, 'সঠিক পরিমাণ দিন', kOrange);
      return;
    }
    final cost = double.tryParse(_pCost.text) ?? 0;
    if (cost <= 0) {
      showToast(context, 'ক্রয় মূল্য দিন', kOrange);
      return;
    }
    final price = double.tryParse(_pPrice.text) ?? 0;
    if (price <= 0) {
      showToast(context, 'বিক্রয় মূল্য দিন', kOrange);
      return;
    }
    Store.I.addProduct(
      _pName.text.trim(),
      qty,
      _pUnit,
      cost,
      price,
      _pDate,
      supplierName: _pSupplierName.text.trim(),
      supplierMobile: rawPhone(_pSupplierMobile.text.trim()),
    );
    final name = _pName.text.trim();
    _pName.clear();
    _pQty.clear();
    _pCost.clear();
    _pPrice.clear();
    _pSupplierName.clear();
    _pSupplierMobile.text = '+88';
    setState(() => _pDate = DateTime.now());
    showToast(context, '$name যোগ হয়েছে', kGreen);
    widget.onDone(2);
  }

  void _submitSale() {
    final p = Store.I.byId(_sProductId ?? '');
    if (p == null) {
      showToast(context, 'পণ্য নির্বাচন করুন', kOrange);
      return;
    }
    if (_sBuyerName.text.trim().isEmpty) {
      showToast(context, 'ক্রেতার নাম দিন', kOrange);
      return;
    }
    if (rawPhone(_sBuyerMobile.text.trim()) == '+88') {
      showToast(context, 'ক্রেতার মোবাইল নম্বর দিন', kOrange);
      return;
    }
    final qty = double.tryParse(_sQty.text) ?? 0;
    if (qty <= 0) {
      showToast(context, 'বিক্রিত পরিমাণ দিন', kOrange);
      return;
    }
    final price = double.tryParse(_sPrice.text) ?? 0;
    if (price <= 0) {
      showToast(context, 'বিক্রয় মূল্য দিন', kOrange);
      return;
    }
    final over = Store.I.recordSale(p, qty, price, _sDate,
        buyerName: _sBuyerName.text.trim(), buyerMobile: rawPhone(_sBuyerMobile.text.trim()));
    _sQty.clear();
    _sPrice.clear();
    _sBuyerName.clear();
    _sBuyerMobile.text = '+88';
    setState(() {
      _sProductId = null;
      _sDate = DateTime.now();
    });
    if (over) {
      showToast(context, 'সতর্কতা! স্টকের চেয়ে বেশি বিক্রি — স্টক ঋণাত্মক', kOrange);
    } else {
      showToast(context, 'বিক্রয় সম্পন্ন হয়েছে', kGreen);
    }
    widget.onDone(3);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        if (!saleMode) ..._productForm() else ..._saleForm(),
      ],
    );
  }

  List<Widget> _productForm() {
    // build shared name pool (suppliers + buyers)
    final seen = <String>{};
    final nameList = <String>[];
    final mobileList = <String>[];
    final nameToMobile = <String, String>{};
    final mobileToName = <String, String>{};
    void addPerson(String n, String raw) {
      if (n.isEmpty) return;
      final mob = fmtPhone(raw);
      final key = '$n|$raw';
      if (seen.contains(key)) return;
      seen.add(key);
      nameToMobile[n] = raw;
      if (raw.isNotEmpty && raw != '+88') mobileToName[mob] = n;
      nameList.add(mob != '+88' ? '$n · $mob' : n);
      if (raw.isNotEmpty && raw != '+88') mobileList.add('$mob · $n');
    }

    for (final p in Store.I.products) {
      addPerson(p.supplierName.trim(), rawPhone(p.supplierMobile));
    }
    for (final x in Store.I.sales) {
      addPerson(x.buyerName.trim(), rawPhone(x.buyerMobile));
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('সরবরাহকারীর নাম'),
            SuggestTextField(
                controller: _pSupplierName,
                hint: 'নাম দিন',
                suggestions: nameList,
                onChanged: (v) {
                  final name = v.contains(' · ') ? v.split(' · ').first.trim() : v;
                  _pSupplierName.text = name;
                  final clean = name.trim();
                  final m = nameToMobile[clean];
                  if (m != null && m != '+88') _pSupplierMobile.text = fmtPhone(m);
                  setState(() {});
                }),
          ])),
          const SizedBox(width: 11),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('সরবরাহকারীর মোবাইল'),
            SuggestTextField(
                controller: _pSupplierMobile,
                onChanged: (v) {
                  final mob = v.contains(' · ') ? v.split(' · ').first.trim() : v;
                  _pSupplierMobile.text = mob;
                  final clean = mob.trim();
                  final n = mobileToName[clean];
                  if (n != null && n.isNotEmpty) _pSupplierName.text = n;
                  setState(() {});
                },
                hint: 'মোবাইল নম্বর',
                keyboardType: TextInputType.phone,
                inputFormatters: [PhoneFormatter()],
                suggestions: mobileList),
          ])),
        ],
      ),
      const SizedBox(height: 13),
      fieldLabel('পণ্যের নাম'),
      TextField(
          controller: _pName,
          style: const TextStyle(color: kInk, fontSize: 15),
          decoration: fieldDeco('যেমনঃ সয়াবিন তেল')),
      const SizedBox(height: 13),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              fieldLabel('পরিমাণ'),
              TextField(
                  controller: _pQty,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  style: const TextStyle(color: kInk, fontSize: 15),
                  decoration: fieldDeco('০')),
            ]),
          ),
          const SizedBox(width: 11),
          SizedBox(
            width: 128,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              fieldLabel('একক'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder, width: 1.5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _pUnit,
                    isExpanded: true,
                    style: const TextStyle(color: kInk, fontSize: 15),
                    items: const ['পিস', 'কেজি', 'লিটার', 'হালি', 'প্যাকেট']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _pUnit = v!),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
      const SizedBox(height: 13),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('ক্রয় মূল্য (একক)'),
            TextField(
                controller: _pCost,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                style: const TextStyle(color: kInk, fontSize: 15),
                decoration: fieldDeco('৳ ০')),
          ])),
          const SizedBox(width: 11),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('বিক্রয় মূল্য (একক)'),
            TextField(
                controller: _pPrice,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                keyboardType: TextInputType.number,
                style: const TextStyle(color: kInk, fontSize: 15),
                decoration: fieldDeco('৳ ০')),
          ])),
        ],
      ),
      const SizedBox(height: 13),
      fieldLabel('যোগের তারিখ'),
      _dateField(_pDate, () => _pickDate(true)),
      const SizedBox(height: 22),
      _submitButton(
        'পণ্য সংরক্ষণ করুন',
        _submitProduct,
        enabled: _pSupplierName.text.trim().isNotEmpty && rawPhone(_pSupplierMobile.text.trim()) != '+88',
      ),
    ];
  }

  List<Widget> _saleForm() {
    final products = Store.I.products;
    final sel = Store.I.byId(_sProductId ?? '');
    final qty = double.tryParse(_sQty.text) ?? 0;
    final price = double.tryParse(_sPrice.text) ?? 0;
    final over = sel != null && qty > sel.qty;
    // build shared name pool (buyers + suppliers)
    final seen = <String>{};
    final nameList = <String>[];
    final mobileList = <String>[];
    final nameToMobile = <String, String>{};
    final mobileToName = <String, String>{};
    void addPerson(String n, String raw) {
      if (n.isEmpty) return;
      final mob = fmtPhone(raw);
      final key = '$n|$raw';
      if (seen.contains(key)) return;
      seen.add(key);
      nameToMobile[n] = raw;
      if (raw.isNotEmpty && raw != '+88') mobileToName[mob] = n;
      nameList.add(mob != '+88' ? '$n · $mob' : n);
      if (raw.isNotEmpty && raw != '+88') mobileList.add('$mob · $n');
    }

    for (final x in Store.I.sales) {
      addPerson(x.buyerName.trim(), rawPhone(x.buyerMobile));
    }
    for (final p in Store.I.products) {
      addPerson(p.supplierName.trim(), rawPhone(p.supplierMobile));
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('ক্রেতার নাম'),
            SuggestTextField(
                controller: _sBuyerName,
                hint: 'নাম দিন',
                suggestions: nameList,
                onChanged: (v) {
                  final name = v.contains(' · ') ? v.split(' · ').first.trim() : v;
                  _sBuyerName.text = name;
                  final clean = name.trim();
                  final raw = nameToMobile[clean];
                  if (raw != null && raw != '+88') _sBuyerMobile.text = fmtPhone(raw);
                  setState(() {});
                }),
          ])),
          const SizedBox(width: 11),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('ক্রেতার মোবাইল'),
            SuggestTextField(
                controller: _sBuyerMobile,
                hint: 'মোবাইল নম্বর',
                keyboardType: TextInputType.phone,
                inputFormatters: [PhoneFormatter()],
                suggestions: mobileList,
                onChanged: (v) {
                  final mob = v.contains(' · ') ? v.split(' · ').first.trim() : v;
                  _sBuyerMobile.text = mob;
                  final clean = mob.trim();
                  final n = mobileToName[clean];
                  if (n != null && n.isNotEmpty) _sBuyerName.text = n;
                  setState(() {});
                }),
          ])),
        ],
      ),
      const SizedBox(height: 13),
      fieldLabel('পণ্য নির্বাচন করুন'),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder, width: 1.5)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _sProductId,
            isExpanded: true,
            hint: const Text('— পণ্য বাছুন —', style: TextStyle(color: Color(0xFFABA6C2), fontSize: 15)),
            style: const TextStyle(color: kInk, fontSize: 15),
            items: products
                .map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.name} (স্টক ${bn(numStr(p.qty))} ${p.unit})', overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _sProductId = v),
          ),
        ),
      ),
      if (sel != null) ...[
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: over ? const Color(0xFFFDECEC) : const Color(0xFFE7F6EE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(over ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 18, color: over ? kRed : kGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                over
                    ? 'সতর্কতা! স্টক মাত্র ${bn(numStr(sel.qty))} ${sel.unit}'
                    : 'স্টকে আছে ${bn(numStr(sel.qty))} ${sel.unit}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: over ? kRed : kGreen),
              ),
            ),
          ]),
        ),
      ],
      const SizedBox(height: 13),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('বিক্রিত পরিমাণ'),
            TextField(
                controller: _sQty,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: kInk, fontSize: 15),
                decoration: fieldDeco('০')),
          ])),
          const SizedBox(width: 11),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel('বিক্রয় মূল্য (একক)'),
            TextField(
                controller: _sPrice,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: kInk, fontSize: 15),
                decoration: fieldDeco('৳ ০')),
          ])),
        ],
      ),
      if (sel != null) ...[
        const SizedBox(height: 8),
        _profitLossWidget(sel.cost, double.tryParse(_sPrice.text) ?? 0),
      ],
      const SizedBox(height: 13),
      fieldLabel('বিক্রয়ের তারিখ'),
      _dateField(_sDate, () => _pickDate(false)),
      const SizedBox(height: 13),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFFF3EFFE), borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('মোট বিক্রয়',
                style: TextStyle(fontSize: 13.5, color: Color(0xFF6A6580), fontWeight: FontWeight.w500)),
            Text(taka(qty * price), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: kPrimary)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _submitButton(
        'বিক্রয় নিশ্চিত করুন',
        _submitSale,
        enabled: _sBuyerName.text.trim().isNotEmpty && rawPhone(_sBuyerMobile.text.trim()) != '+88',
      ),
    ];
  }

  Widget _dateField(DateTime d, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder, width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmtDate(d), style: const TextStyle(color: kInk, fontSize: 15)),
              const Icon(Icons.calendar_today_outlined, color: kMute, size: 18),
            ],
          ),
        ),
      );

  Widget _profitLossWidget(double cost, double salePrice) {
    if (salePrice <= 0) return const SizedBox.shrink();
    final diff = salePrice - cost;
    final Color bg, iconClr, txtClr;
    final IconData icon;
    final String label;
    if (diff > 0) {
      bg = const Color(0xFFE7F6EE);
      iconClr = kGreen;
      txtClr = kGreen;
      icon = Icons.trending_up;
      label = 'লাভ ${taka(diff)}';
    } else if (diff < 0) {
      bg = const Color(0xFFFDECEC);
      iconClr = kRed;
      txtClr = kRed;
      icon = Icons.trending_down;
      label = 'ক্ষতি ${taka(diff.abs())}';
    } else {
      bg = const Color(0xFFFFF8E1);
      iconClr = kOrange;
      txtClr = kOrange;
      icon = Icons.remove_circle_outline;
      label = 'লাভ নেই';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, size: 18, color: iconClr),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txtClr)),
        const Spacer(),
        Text('ক্রয় মূল্য ${taka(cost)}', style: const TextStyle(fontSize: 12, color: kMute)),
      ]),
    );
  }

  Widget _submitButton(String t, VoidCallback onTap, {bool enabled = true}) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient:
                  enabled ? kHeaderGradient : const LinearGradient(colors: [Color(0xFFD8D2EA), Color(0xFFD8D2EA)]),
              borderRadius: BorderRadius.circular(15),
              boxShadow:
                  enabled ? const [BoxShadow(color: Color(0x526A47E0), blurRadius: 18, offset: Offset(0, 8))] : null,
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 17),
              child: Text(t,
                  style: TextStyle(
                      color: enabled ? Colors.white : const Color(0xFFB0ABC4),
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
}
