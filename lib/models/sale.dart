class Sale {
  String id, productId, name, date;
  double qty, price, cost;
  Sale({
    required this.id,
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.cost,
    required this.date,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'name': name,
        'qty': qty,
        'price': price,
        'cost': cost,
        'date': date,
      };
  factory Sale.fromJson(Map j) => Sale(
        id: j['id'],
        productId: j['productId'],
        name: j['name'],
        qty: (j['qty'] as num).toDouble(),
        price: (j['price'] as num).toDouble(),
        cost: (j['cost'] as num).toDouble(),
        date: j['date'],
      );
}
