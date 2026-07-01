import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../store/store.dart';

// ============================================================
// Shared widgets
// ============================================================
bool requireLogin(BuildContext context) {
  if (!Store.I.loggedIn) {
    showToast(context, 'প্রথমে লগইন করুন', kOrange);
    return false;
  }
  return true;
}

void showToast(BuildContext c, String msg, Color color) {
  final overlay = Overlay.of(c, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 92,
      left: 40,
      right: 40,
      child: Material(
        color: Colors.transparent,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(13),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2400), () => entry.remove());
}

BoxDecoration get cardDeco => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Color(0x0F5A46B4), blurRadius: 12, offset: Offset(0, 3))],
    );

InputDecoration fieldDeco(String hint, {Widget? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFABA6C2), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder, width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
    );

Widget fieldLabel(String t) => Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(t, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF6A6580))),
    );

Widget avatar(String name, int tintI, {double size = 52, double radius = 14, double font = 22}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: tintFor(tintI), borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Text(name.isNotEmpty ? name.substring(0, 1) : '?',
          style: TextStyle(fontSize: font, fontWeight: FontWeight.w700, color: inkFor(tintI))),
    );

// ============================================================
// Search box
// ============================================================
class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchBox({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: kInk, fontSize: 14.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFABA6C2), fontSize: 14.5),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFA7A2BC), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
      ),
    );
  }
}
