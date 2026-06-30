import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PaymentService {
  static Future<Map<String, dynamic>?> createRazorpayOrder(
    double amount,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${AppConfig.razorpayKey}:'))}',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(),
          'currency': 'INR',
          'receipt': description,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> verifyPayment(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    return true;
  }
}
