import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/presentation/providers/cart_provider.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),

      body: Column(
        children: [
          /// LIST ITEM 
          Expanded(
            child: ListView(
              children: cart.items.map((item) {
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('Rp ${item.price}'),
                );
              }).toList(),
            ),
          ),

          /// BUTTON 
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total"),
                    Text("Rp ${cart.totalPrice}"),
                  ],
                ),

                const SizedBox(height: 20),

                /// BUTTON CHECKOUT
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await cart.checkout();

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Checkout berhasil'),
                          ),
                        );

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/dashboard',
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Checkout gagal'),
                          ),
                        );
                      }
                    },
                    child: const Text("Beli Sekarang"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}