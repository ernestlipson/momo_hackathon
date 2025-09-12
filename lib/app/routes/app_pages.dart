import 'package:get/get.dart';
import 'package:momo_hackathon/app/data/services/local_auth_db_service.dart';

import '../modules/main_navigation/bindings/main_navigation_binding.dart';
import '../modules/main_navigation/views/main_navigation_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/sms_scanner/bindings/sms_scanner_binding.dart';
import '../modules/sms_scanner/views/sms_scanner_view.dart';
import '../modules/fraud_messages/bindings/fraud_messages_binding.dart';
import '../modules/fraud_messages/views/fraud_messages_view.dart';
import '../modules/news_detail/bindings/news_detail_binding.dart';
import '../modules/news_detail/views/news_detail_view.dart';
import '../modules/detailed_stats/bindings/detailed_stats_binding.dart';
import '../modules/detailed_stats/views/detailed_stats_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_step1_view.dart';
import '../modules/signup/views/signup_step2_view.dart';
import '../modules/signup_success/bindings/signup_success_binding.dart';
import '../modules/signup_success/views/signup_success_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static String get INITIAL => LocalAuthDbService.hasLoggedInBefore
      ? Routes.MAIN_NAVIGATION
      : Routes.SIGNUP_STEP1;

  static final routes = [
    GetPage(
      name: _Paths.MAIN_NAVIGATION,
      page: () => const MainNavigationView(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.SMS_SCANNER,
      page: () => const SmsScannerView(),
      binding: SmsScannerBinding(),
    ),
    GetPage(
      name: _Paths.FRAUD_MESSAGES,
      page: () => const FraudMessagesView(),
      binding: FraudMessagesBinding(),
    ),
    GetPage(
      name: _Paths.NEWS_DETAIL,
      page: () => const NewsDetailView(),
      binding: NewsDetailBinding(),
    ),
    GetPage(
      name: _Paths.ARTICLE_DETAIL,
      page: () => const NewsDetailView(), // Reusing news detail for now
      binding: NewsDetailBinding(),
    ),
    GetPage(
      name: _Paths.DETAILED_STATS,
      page: () => const DetailedStatsView(),
      binding: DetailedStatsBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP_STEP1,
      page: () => const SignupStep1View(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP_STEP2,
      page: () => const SignupStep2View(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP_SUCCESS,
      page: () => const SignupSuccessView(),
      binding: SignupSuccessBinding(),
    ),
  ];
}
