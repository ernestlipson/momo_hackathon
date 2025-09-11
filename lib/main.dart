import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/data/services/local_auth_db_service.dart';
import 'app/data/services/background_sms_worker.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/service_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LocalAuthDbService.init();
  await BackgroundSmsWorker.initialize();

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
