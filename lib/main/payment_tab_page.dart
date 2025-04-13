
import 'package:flutter/material.dart';

class PaymentTabPage extends StatefulWidget {
  const PaymentTabPage({super.key});

  @override
  State<PaymentTabPage> createState() => _PaymentTabPageState();
}

class _PaymentTabPageState extends State<PaymentTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        color: Colors.orange,
      ),
    );
  }
}
