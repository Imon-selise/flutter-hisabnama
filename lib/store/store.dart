import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/addition.dart';

// ============================================================
// Store (state + persistence)
// ============================================================
class Store extends ChangeNotifier {
  Store._();
  static final Store I = Store._();
  static const _key = 'hishabnama_flutter_v1';
  static const _authLoggedInKey = 'hishabnama_auth_loggedIn';
  static const _authUsernameKey = 'hishabnama_auth_username';
  final _rnd = Random();

  List<Product> products = [];
  List<Sale> sales = [];
  List<Addition> additions = [];

  String _uid(String p) => '$p${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_rnd.nextInt(9999)}';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final m = jsonDecode(raw);
      products = (m['products'] as List).map((e) => Product.fromJson(e)).toList();
      sales = (m['sales'] as List).map((e) => Sale.fromJson(e)).toList();
      additions = (m['additions'] as List).map((e) => Addition.fromJson(e)).toList();
      // clean up orphaned data (products that were deleted before the fix)
      final ids = products.map((p) => p.id).toSet();
      additions.removeWhere((a) => !ids.contains(a.productId));
      sales.removeWhere((s) => !ids.contains(s.productId));
    }
    // restore auth state
    loggedIn = prefs.getBool(_authLoggedInKey) ?? false;
    loggedInUsername = prefs.getString(_authUsernameKey);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'products': products.map((e) => e.toJson()).toList(),
        'sales': sales.map((e) => e.toJson()).toList(),
        'additions': additions.map((e) => e.toJson()).toList(),
      }),
    );
  }

  // ---- mutations ----
  void addProduct(String name, double qty, String unit, double cost, double price, DateTime date,
      {String supplierName = '', String supplierMobile = ''}) {
    final id = _uid('p');
    final iso = date.toIso8601String();
    products.add(Product(
      id: id,
      name: name,
      unit: unit,
      cost: cost,
      price: price,
      qty: qty,
      date: iso,
      tintI: products.length,
      supplierName: supplierName,
      supplierMobile: supplierMobile,
    ));
    additions.add(Addition(id: _uid('a'), productId: id, qty: qty, cost: cost, date: iso));
    _save();
    notifyListeners();
  }

  void updateProduct(String id, String name, double qty, String unit, double cost, double price,
      {String supplierName = '', String supplierMobile = ''}) {
    final p = products.firstWhere((p) => p.id == id);
    p.name = name;
    p.qty = qty;
    p.unit = unit;
    p.cost = cost;
    p.price = price;
    p.supplierName = supplierName;
    p.supplierMobile = supplierMobile;
    _save();
    notifyListeners();
  }

  /// returns true if sold more than stock (over-sell warning)
  bool recordSale(Product p, double qty, double price, DateTime date,
      {String buyerName = '', String buyerMobile = ''}) {
    final over = qty > p.qty;
    sales.add(Sale(
      id: _uid('s'),
      productId: p.id,
      name: p.name,
      qty: qty,
      price: price,
      cost: p.cost,
      date: date.toIso8601String(),
      buyerName: buyerName,
      buyerMobile: buyerMobile,
    ));
    p.qty -= qty;
    _save();
    notifyListeners();
    return over;
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    additions.removeWhere((a) => a.productId == id);
    sales.removeWhere((s) => s.productId == id);
    _save();
    notifyListeners();
  }

  Future<void> deleteSale(String id) async {
    sales.removeWhere((s) => s.id == id);
    await _save();
    notifyListeners();
  }

  // ---- queries ----
  Product? byId(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  double get totalStockValue => products.fold(0.0, (s, p) => s + p.qty * p.cost);

  // ---- auth ----
  bool loggedIn = false;
  String? loggedInUsername;

  Future<bool> login(String username, String password) async {
    if (username == 'shopno' && password == '@shopno!2026') {
      loggedIn = true;
      loggedInUsername = username;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authLoggedInKey, true);
      await prefs.setString(_authUsernameKey, username);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    loggedIn = false;
    loggedInUsername = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authLoggedInKey, false);
    await prefs.remove(_authUsernameKey);
    notifyListeners();
  }
}
