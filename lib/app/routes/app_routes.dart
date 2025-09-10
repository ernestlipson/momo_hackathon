part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const MAIN_NAVIGATION = _Paths.MAIN_NAVIGATION;
  static const HOME = _Paths.HOME;
  static const HISTORY = _Paths.HISTORY;
  static const SETTINGS = _Paths.SETTINGS;
  static const SMS_SCANNER = _Paths.SMS_SCANNER;
  static const NEWS_DETAIL = _Paths.NEWS_DETAIL;
  static const ARTICLE_DETAIL = _Paths.ARTICLE_DETAIL;
  static const DETAILED_STATS = _Paths.DETAILED_STATS;
  static const LOGIN = _Paths.LOGIN;
  static const SIGNUP_STEP1 = _Paths.SIGNUP_STEP1;
  static const SIGNUP_STEP2 = _Paths.SIGNUP_STEP2;
  static const SIGNUP_SUCCESS = _Paths.SIGNUP_SUCCESS;
}

abstract class _Paths {
  _Paths._();
  static const MAIN_NAVIGATION = '/';
  static const HOME = '/home';
  static const HISTORY = '/history';
  static const SETTINGS = '/settings';
  static const SMS_SCANNER = '/sms-scanner';
  static const NEWS_DETAIL = '/news-detail';
  static const ARTICLE_DETAIL = '/article-detail';
  static const DETAILED_STATS = '/detailed-stats';
  static const LOGIN = '/login';
  static const SIGNUP_STEP1 = '/signup';
  static const SIGNUP_STEP2 = '/signup-step2';
  static const SIGNUP_SUCCESS = '/signup-success';
}
