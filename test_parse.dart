import 'dart:convert';
import 'lib/features/orders/data/models/order_model.dart';

void main() {
  String jsonStr = '''
  {
    "ID": 1,
    "CreatedAt": "2026-07-01T22:29:56.575+07:00",
    "UpdatedAt": "2026-07-01T22:29:56.575+07:00",
    "DeletedAt": null,
    "user_id": 4,
    "total_price": 650000,
    "status": "menunggu",
    "payment_status": "paid",
    "order_items": [
      {
        "ID": 1,
        "CreatedAt": "2026-07-01T22:29:56.594+07:00",
        "UpdatedAt": "2026-07-01T22:29:56.594+07:00",
        "DeletedAt": null,
        "order_id": 1,
        "product_id": 79,
        "quantity": 1,
        "price": 650000,
        "product": {
          "ID": 79,
          "CreatedAt": "2026-06-26T21:14:05.796+07:00",
          "UpdatedAt": "2026-06-26T21:14:05.796+07:00",
          "DeletedAt": null,
          "name": "Ganti Kaca Depan Samsung S22",
          "description": "Ganti kaca depan original corning",
          "price": 650000,
          "stock": 15,
          "category": "Layar",
          "image_url": "https://picsum.photos/seed/layar10/400/400",
          "is_active": true
        }
      }
    ]
  }
  ''';

  try {
    final parsed = jsonDecode(jsonStr);
    final order = OrderModel.fromJson(parsed);
    print('Success! Order ID: \${order.id}, Total: \${order.totalPrice}');
  } catch (e, stacktrace) {
    print('Error: \$e');
    print(stacktrace);
  }
}
