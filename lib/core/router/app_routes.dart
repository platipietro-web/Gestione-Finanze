import '../time/year_month.dart';

/// Percorsi dell'app. Sul web sono anche gli URL visibili.
abstract final class AppRoutes {
  static const splash = '/avvio';
  static const login = '/accedi';
  static const signUp = '/registrati';
  static const forgotPassword = '/password-dimenticata';
  static const resetPassword = '/reimposta-password';
  static const onboarding = '/benvenuto';

  static const dashboard = '/';
  static const assets = '/patrimonio';
  static const investments = '/investimenti';
  static const history = '/storico';
  static const settings = '/impostazioni';
  static const update = '/aggiorna';

  static String historyDetail(String id) => '$history/$id';
  static String editSnapshot(String id) => '$history/$id/modifica';
  static String updateForMonth(YearMonth month) =>
      '$update?mese=${month.isoMonth}';

  static const publicPaths = {login, signUp, forgotPassword, resetPassword};

  /// Parametro con la pagina richiesta prima del login.
  static const fromParam = 'da';
}
