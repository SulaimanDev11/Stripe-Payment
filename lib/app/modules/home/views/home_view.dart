import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  Map<String, dynamic>? paymentsIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Payment'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              await makePayment();
            },
            child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(color: Colors.green),
                child: Center(
                  child: Text('Pay'),
                )),
          ),
        ],
      ),
      // Center(
      //     child: ElevatedButton(
      //   onPressed: () async {
      //     final paymentMethod = await Stripe.instance
      //         .createPaymentMethod(PaymentMethodParams.card());
      //   },
      //   child: Text('Pay Now'),
      // )),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentsIntentData = await creatPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentsIntentData!['client_secret'],
            applePay: true,
            googlePay: true,
            style: ThemeMode.dark,
            merchantCountryCode: 'US',
            merchantDisplayName: 'Sulaiman'),
      );

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
              clientSecret: paymentsIntentData!['client_secret'],
              confirmPayment: true));
      paymentsIntentData = null;
      Get.snackbar('Successful', 'Paid Successfully');
    } on StripeException catch (e) {
      print(e.toString());
      showDialog(
        context: Get.context!,
        builder: (_) => AlertDialog(
          content: Text('Cancelled'),
        ),
      );
    }
  }

  creatPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
          Uri.parse('https://dashboard.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51KHP15Dv7hqQCbNCoey6lU0qC0nBDRkC3sdUpb1ICZFjLEqYw4vBW6wfGlUHNEKyGDdnscQt4KkkfmZC95RUKtzC00Vqj25L2K",
            "Content-Type": "application/x-www-form-urlencoded"
          });
      jsonDecode(response.body.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
