class Product {
  String id, name, unit, date;
  double cost, price, qty;
  int tintI;
  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.cost,
    required this.price,
    required this.qty,
    required this.date,
    required this.tintI,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'cost': cost,
        'price': price,
        'qty': qty,
        'date': date,
        'tintI': tintI,
      };
  factory Product.fromJson(Map j) => Product(
        id: j['id'],
        name: j['name'],
        unit: j['unit'],
        cost: (j['cost'] as num).toDouble(),
        price: (j['price'] as num).toDouble(),
        qty: (j['qty'] as num).toDouble(),
        date: j['date'],
        tintI: j['tintI'] ?? 0,
      );
}
