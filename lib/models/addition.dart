class Addition {
  String id, productId, date;
  double qty, cost;
  Addition({
    required this.id,
    required this.productId,
    required this.qty,
    required this.cost,
    required this.date,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'qty': qty,
        'cost': cost,
        'date': date,
      };
  factory Addition.fromJson(Map j) => Addition(
        id: j['id'],
        productId: j['productId'],
        qty: (j['qty'] as num).toDouble(),
        cost: (j['cost'] as num).toDouble(),
        date: j['date'],
      );
}
