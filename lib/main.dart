import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51KHP15Dv7hqQCbNCwHYu9Q8ny7h9dceL79s53lt4flKZjpNhq7vCZKBDRFDvmFU5ecAz7OfiZBGvjOF8T84bNwKf00oDVYDBGm';
  await Stripe.instance.applySettings();
  runApp(
    GetMaterialApp(
      title: "Stripe Payment",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(primarySwatch: Colors.blue),
    ),
  );
}
