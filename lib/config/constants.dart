import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================
// Palette
// ============================================================
const kPrimary = Color(0xFF6A47E0);
const kPrimaryLight = Color(0xFF8367F0);
const kBg = Color(0xFFF4F2FB);
const kInk = Color(0xFF2C2840);
const kMute = Color(0xFF9A95B2);
const kSubInk = Color(0xFF5B5670);
const kGreen = Color(0xFF1FAF6B);
const kRed = Color(0xFFE5484D);
const kBorder = Color(0xFFE7E2F4);
const kOrange = Color(0xFFE0892B);

const kHeaderGradient = LinearGradient(
  colors: [kPrimaryLight, kPrimary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _tints = [
  Color(0xFFFDE3D6),
  Color(0xFFE0F0E6),
  Color(0xFFFBE6EE),
  Color(0xFFE4E9FC),
  Color(0xFFFCF2D8),
  Color(0xFFE9E1FB),
];
const _inks = [
  Color(0xFFD2773C),
  Color(0xFF3E9B6B),
  Color(0xFFD04B7E),
  Color(0xFF4862C8),
  Color(0xFFC29A1C),
  Color(0xFF7E5AD6),
];
Color tintFor(int i) => _tints[i % _tints.length];
Color inkFor(int i) => _inks[i % _inks.length];

// ============================================================
// Formatting helpers
// ============================================================
String bn(Object n) {
  const d = '০১২৩৪৫৬৭৮৯';
  return n.toString().split('').map((c) {
    final i = '0123456789'.indexOf(c);
    return i >= 0 ? d[i] : c;
  }).join();
}

String _group(int v) {
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (v < 0 ? '-' : '') + buf.toString();
}

String taka(num v) => '৳${bn(_group(v.round()))}';

String fmtDate(DateTime d) => bn('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');

String numStr(num v) {
  if (v == v.roundToDouble()) return v.round().toString();
  return v.toString();
}

// ============================================================
// Phone number helpers
// ============================================================

/// Format phone: +8801521325211 → +880 1521-325211
String fmtPhone(String raw) {
  if (raw.isEmpty) return '';
  final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
  String s = digits.startsWith('+') ? digits.substring(1) : digits;
  if (!s.startsWith('880') && s.isNotEmpty) s = '880$s';
  if (s.length <= 3) return '+$s';
  final code = s.substring(0, 3);
  final rest = s.substring(3);
  if (rest.length <= 4) return '+$code $rest';
  return '+$code ${rest.substring(0, 4)}-${rest.substring(4)}';
}

/// Strips formatting, returns raw like +8801521325211
String rawPhone(String formatted) {
  final d = formatted.replaceAll(RegExp(r'[^\d+]'), '');
  if (d.startsWith('+')) return d;
  return '+880$d';
}

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue v) {
    // Extract only digits
    final cleaned = v.text.replaceAll(RegExp(r'[^\d]'), '');
    // Separate the mandatory 88 prefix from user digits
    final userDigits = cleaned.startsWith('88') && cleaned.length >= 2 ? cleaned.substring(2) : cleaned;
    // Cap user input to 11 digits
    final capped = userDigits.length > 11 ? userDigits.substring(0, 11) : userDigits;
    final digits = '88$capped';

    if (digits.length <= 3) {
      return TextEditingValue(text: '+$digits', selection: TextSelection.collapsed(offset: digits.length + 1));
    }
    final body = digits.substring(3);
    if (body.isEmpty) {
      return TextEditingValue(text: '+${digits.substring(0, 3)}', selection: const TextSelection.collapsed(offset: 4));
    }
    String formatted;
    if (body.length <= 4) {
      formatted = '+${digits.substring(0, 3)} $body';
    } else {
      formatted = '+${digits.substring(0, 3)} ${body.substring(0, 4)}-${body.substring(4)}';
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
