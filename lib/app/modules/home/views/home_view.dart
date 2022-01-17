import 'dart:convert';
import 'dart:developer';

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
      body: Container(
        height: Get.height,
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await makePayment();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  margin: EdgeInsets.symmetric(horizontal: 100),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                    child: Text('Pay Now',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25)),
                  )),
            ),
          ],
        ),
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
      paymentsIntentData =
          await creatPaymentIntent('20', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret:
                      paymentsIntentData!['client_secret'],
                  applePay: true,
                  googlePay: true,
                  testEnv: true,
                  style: ThemeMode.dark,
                  merchantCountryCode: 'US',
                  merchantDisplayName: 'ANNIE'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              parameters: PresentPaymentSheetParameters(
        clientSecret: paymentsIntentData!['client_secret'],
        confirmPayment: true,
      ))
          .then((newValue) {
        print('payment intent' + paymentsIntentData!['id'].toString());
        print(
            'payment intent' + paymentsIntentData!['client_secret'].toString());
        print('payment intent' + paymentsIntentData!['amount'].toString());
        print('payment intent' + paymentsIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(SnackBar(content: Text("paid successfully")));

        paymentsIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: Get.context!,
          builder: (_) => AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  creatPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51KHP15Dv7hqQCbNCoey6lU0qC0nBDRkC3sdUpb1ICZFjLEqYw4vBW6wfGlUHNEKyGDdnscQt4KkkfmZC95RUKtzC00Vqj25L2K',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      log(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print(e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = (int.parse(amount)) * 100;
    return price.toString();
  }
}
