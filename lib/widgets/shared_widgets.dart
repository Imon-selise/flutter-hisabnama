import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
// Search box with autocomplete suggestions
// ============================================================
class SearchBox extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final List<String> suggestions;
  const SearchBox({super.key, required this.hint, required this.onChanged, this.suggestions = const []});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  String _text = '';
  bool _suppressChange = false;

  List<String> get _filtered {
    if (_text.isEmpty) return [];
    final q = banglaToEnglish(_text.toLowerCase());
    return widget.suggestions.where((s) => banglaToEnglish(s.toLowerCase()).contains(q)).take(6).toList();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: (v) {
            _text = v;
            if (!_suppressChange) widget.onChanged(v);
            setState(() {});
          },
          onSubmitted: (v) {
            widget.onChanged(v);
            _focusNode.unfocus();
          },
          style: const TextStyle(color: kInk, fontSize: 14.5),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFFABA6C2), fontSize: 14.5),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFA7A2BC), size: 20),
            suffixIcon: _text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Color(0xFFA7A2BC)),
                    onPressed: () {
                      _ctrl.clear();
                      _text = '';
                      widget.onChanged('');
                      _focusNode.unfocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
          ),
        ),
        if (_text.isNotEmpty && _filtered.isNotEmpty && _focusNode.hasFocus)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x1A5A46B4), blurRadius: 14, offset: Offset(0, 6)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _filtered.map((s) {
                final isLast = _filtered.last == s;
                return InkWell(
                  onTap: () {
                    _suppressChange = true;
                    _ctrl.text = s;
                    _ctrl.selection = TextSelection.collapsed(offset: s.length);
                    _text = s;
                    _suppressChange = false;
                    _focusNode.unfocus();
                    widget.onChanged(s);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1EEF8))),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: Color(0xFFA7A2BC)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(s, style: const TextStyle(fontSize: 14, color: kInk)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

/// Convert Bangla digits to English for search matching
String banglaToEnglish(String s) {
  const b = '০১২৩৪৫৬৭৮৯';
  const e = '0123456789';
  return s.split('').map((c) {
    final i = b.indexOf(c);
    return i >= 0 ? e[i] : c;
  }).join();
}

// ============================================================
// Text field with autocomplete suggestions
// ============================================================
class SuggestTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final List<String> suggestions;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const SuggestTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.suggestions = const [],
    this.inputFormatters,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<SuggestTextField> createState() => _SuggestTextFieldState();
}

class _SuggestTextFieldState extends State<SuggestTextField> {
  final _focusNode = FocusNode();
  String _text = '';

  List<String> get _filtered {
    if (_text.isEmpty) return [];
    final q = banglaToEnglish(_text.toLowerCase().trim());
    return widget.suggestions
        .where((s) => s.isNotEmpty && banglaToEnglish(s.toLowerCase()).contains(q))
        .take(6)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _text = widget.controller.text;
    widget.controller.addListener(_onCtrlChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onCtrlChanged() {
    if (_text != widget.controller.text) {
      setState(() => _text = widget.controller.text);
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() => _text = widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCtrlChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(color: kInk, fontSize: 15),
          decoration: fieldDeco(widget.hint),
          onChanged: (v) {
            setState(() => _text = v);
            widget.onChanged?.call(v);
          },
        ),
        if (_focusNode.hasFocus && _text.isNotEmpty && _filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x1A5A46B4), blurRadius: 14, offset: Offset(0, 6)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _filtered.map((s) {
                final isLast = _filtered.last == s;
                return InkWell(
                  onTap: () {
                    widget.controller.text = s;
                    widget.controller.selection = TextSelection.collapsed(offset: s.length);
                    setState(() => _text = s);
                    widget.onChanged?.call(s);
                    _focusNode.unfocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1EEF8))),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history, size: 16, color: Color(0xFFA7A2BC)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(s, style: const TextStyle(fontSize: 14, color: kInk)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
