import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/drawer.dart';
import 'home_tab.dart';
import 'add_tab.dart' show AddTab, AddTabState;
import 'inventory_tab.dart';
import 'sales_tab.dart';
import 'reports_tab.dart';

// ============================================================
// Root screen: header + tabs + bottom nav + drawer
// ============================================================
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int idx = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _addKey = GlobalKey<AddTabState>();

  static const _titles = ['স্বপ্নছোঁয়া গ্রামের খাবার', 'যোগ করুন', 'পণ্য সমূহ', 'বিক্রয় করুন', 'রিপোর্ট'];

  String _titleForIndex() {
    if (idx == 1) {
      final isSale = _addKey.currentState?.isSaleMode ?? false;
      return isSale ? 'বিক্রয় করুন' : 'যোগ করুন';
    }
    return _titles[idx];
  }

  void _goTo(int i) {
    // if (i == 1 && !requireLogin(context)) return;
    // if (i == 1) {
    //   _addKey.currentState?.setMode(false);
    // }
    setState(() => idx = i);
  }

  void _goAddProduct() {
    _addKey.currentState?.setMode(false);
    setState(() => idx = 1);
  }

  void _goAddSale({String? productId}) {
    _addKey.currentState?.setMode(true, productId: productId);
    setState(() => idx = 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Store.I,
      builder: (context, _) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: kBg,
          drawer: AppDrawer(
            onHome: () => _goTo(0),
            onAddProduct: _goAddProduct,
            onAddSale: () => _goAddSale(),
            onInventory: () => _goTo(2),
            onReports: () => _goTo(4),
          ),
          body: Column(
            children: [
              _header(),
              Expanded(
                child: IndexedStack(
                  index: idx,
                  children: [
                    HomeTab(onAddProduct: _goAddProduct, onAddSale: () => _goAddSale()),
                    AddTab(key: _addKey, onDone: _goTo),
                    InventoryTab(onSell: (pid) => _goAddSale(productId: pid)),
                    const SalesTab(),
                    const ReportsTab(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _bottomNav(),
        );
      },
    );
  }

  // ----- gradient header -----
  Widget _header() {
    final isHome = idx == 0;
    return Container(
      decoration: const BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [BoxShadow(color: Color(0x47604AD2), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Row(
            children: [
              _hBtn(Icons.menu, () => _scaffoldKey.currentState?.openDrawer()),
              Expanded(
                child: Column(
                  children: [
                    Text(_titleForIndex(),
                        maxLines: 1,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    if (isHome)
                      Text('আজ ${fmtDate(DateTime.now())}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(.85), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              _loginBtn()
            ],
          ),
        ),
      ),
    );
  }

  Widget _hBtn(IconData ic, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(12)),
          child: Icon(ic, color: Colors.white, size: 21),
        ),
      );

  Widget _loginBtn() {
    final loggedIn = Store.I.loggedIn;
    final iconColor = loggedIn ? Colors.white : const Color.fromARGB(255, 215, 41, 46);
    return InkWell(
      onTap: () => loggedIn ? _showLogoutConfirm() : _showLoginDialog(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: loggedIn ? Colors.white.withOpacity(.16) : Colors.white.withOpacity(.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(loggedIn ? Icons.person : Icons.person_outline, color: iconColor, size: 21),
      ),
    );
  }

  void _showLoginDialog() {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        var _error = '';
        var _showPass = false;
        return StatefulBuilder(
          builder: (ctx, setDState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(
              children: [
                Icon(Icons.lock_outline, color: kPrimary, size: 22),
                SizedBox(width: 10),
                Text('লগইন', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userCtrl,
                  decoration: fieldDeco('ইউজারনেম'),
                  style: const TextStyle(color: kInk, fontSize: 15),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: !_showPass,
                  decoration: fieldDeco('পাসওয়ার্ড',
                      suffix: IconButton(
                        icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off, color: kMute, size: 20),
                        onPressed: () => setDState(() => _showPass = !_showPass),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )),
                  style: const TextStyle(color: kInk, fontSize: 15),
                ),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_error, style: const TextStyle(color: kRed, fontSize: 13)),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
              ElevatedButton(
                onPressed: () async {
                  final ok = await Store.I.login(userCtrl.text.trim(), passCtrl.text);
                  if (ok) {
                    Navigator.pop(ctx);
                  } else {
                    setDState(() => _error = 'ভুল ইউজারনেম বা পাসওয়ার্ড');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('লগইন'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('লগআউট', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('আপনি কি লগআউট করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              await Store.I.logout();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('লগআউট'),
          ),
        ],
      ),
    );
  }

  // ----- bottom nav -----
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFEBF7))),
        boxShadow: [BoxShadow(color: Color(0x125A46B4), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 9, 8, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _navItem(Icons.home_outlined, 'হোম', 0),
              // _navItem(Icons.add, 'যোগ', 1, center: true),
              _navItem(Icons.inventory_2_outlined, 'পণ্য', 2),
              _navItem(Icons.shopping_cart_outlined, 'বিক্রয়', 3),
              _navItem(Icons.bar_chart_rounded, 'রিপোর্ট', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData ic, String label, int i, {bool center = false}) {
    final active = idx == i;
    final clr = active ? kPrimary : kMute;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _goTo(i),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (center)
              Transform.translate(
                offset: const Offset(0, -14),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: kHeaderGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x666A47E0), blurRadius: 14, offset: Offset(0, 6))],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
              )
            else
              SizedBox(height: 26, child: Icon(ic, color: clr, size: 24)),
            Padding(
              padding: EdgeInsets.only(top: center ? 0 : 4),
              child: Text(label,
                  style: TextStyle(fontSize: 11, color: clr, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
