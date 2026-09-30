import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  final Razorpay _razorpay = Razorpay();

  void initialize() {
    // Razorpay setup here
  }

  void dispose() {
    _razorpay.clear();
  }
}