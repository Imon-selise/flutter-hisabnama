import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';

// ============================================================
// Drawer
// ============================================================
class AppDrawer extends StatelessWidget {
  final VoidCallback onHome, onAddProduct, onAddSale, onInventory, onReports;
  const AppDrawer({
    super.key,
    required this.onHome,
    required this.onAddProduct,
    required this.onAddSale,
    required this.onInventory,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    void nav(VoidCallback fn) {
      Navigator.pop(context);
      fn();
    }

    return Drawer(
      width: 300,
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: kHeaderGradient),
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(.35), width: 3),
                    ),
                    alignment: Alignment.center,
                    child: const Text('আ',
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  const Text('আব্দুর রউফ',
                      style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                  Text('০১৭১২৬৫৪৭৮৯', style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 13)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('স্বপ্নছোঁয়া গ্রামের খাবার',
                            style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_up_rounded, color: kPrimary, size: 18),
                      ],
                    ),
                  ),
                  if (Store.I.loggedIn) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('admin',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        Text(Store.I.loggedInUsername ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _item(Icons.shopping_bag_outlined, 'ক্রয় (পণ্য যোগ)', () => nav(onAddProduct)),
                _item(Icons.point_of_sale_outlined, 'বিক্রয়', () => nav(onAddSale)),
                _item(Icons.inventory_2_outlined, 'মালামাল (পণ্য সমূহ)', () => nav(onInventory)),
                _item(Icons.bar_chart_rounded, 'রিপোর্ট', () => nav(onReports)),
                _item(Icons.home_outlined, 'হোম / ড্যাশবোর্ড', () => nav(onHome)),
                _item(Icons.groups_outlined, 'গ্রাহক / সরবরাহকারী', () => Navigator.pop(context)),
                _item(Icons.person_outline, 'ব্যবহারকারী', () => Navigator.pop(context)),
                if (Store.I.loggedIn)
                  _item(Icons.logout, 'লগআউট', () async {
                    await Store.I.logout();
                    Navigator.pop(context);
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData ic, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: const Color(0xFFF1EEFD), borderRadius: BorderRadius.circular(10)),
                child: Icon(ic, color: kPrimary, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(fontSize: 14.5, color: Color(0xFF3A3550), fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right, color: Color(0xFFCFC9E0), size: 18),
            ],
          ),
        ),
      );
}
