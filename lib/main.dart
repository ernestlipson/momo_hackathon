import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/service_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InitialBindings().dependencies();

  runApp(
    GetMaterialApp(
      title: "MoMo Fraud Detection",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: ServiceBindings(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
