import '../../shared/providers/session_providers.dart';
import 'app_routes.dart';

/// Controllo degli accessi: un'unica funzione pura, rivalutata a ogni
/// cambio di sessione o di profilo. Restituisce il percorso verso cui
/// reindirizzare, oppure `null` per restare dove si è.
String? resolveRedirect({required SessionStatus status, required Uri uri}) {
  final path = uri.path;
  final isPublic = AppRoutes.publicPaths.contains(path);
  final from = uri.queryParameters[AppRoutes.fromParam];

  switch (status) {
    case SessionStatus.loading:
      if (path == AppRoutes.splash) return null;
      return _withFrom(AppRoutes.splash, _targetOf(uri));

    case SessionStatus.signedOut:
      // Il reset della password richiede la sessione di recupero.
      if (isPublic && path != AppRoutes.resetPassword) return null;
      final target = path == AppRoutes.splash ? _safe(from) : _targetOf(uri);
      return _withFrom(AppRoutes.login, target);

    case SessionStatus.passwordRecovery:
      return path == AppRoutes.resetPassword ? null : AppRoutes.resetPassword;

    case SessionStatus.needsOnboarding:
      return path == AppRoutes.onboarding ? null : AppRoutes.onboarding;

    case SessionStatus.ready:
      if (isPublic ||
          path == AppRoutes.splash ||
          path == AppRoutes.onboarding) {
        return _safe(from) ?? AppRoutes.dashboard;
      }
      return null;
  }
}

/// La pagina da ricordare: niente per la home e le pagine di servizio.
String? _targetOf(Uri uri) {
  final path = uri.path;
  if (path == AppRoutes.dashboard ||
      path == AppRoutes.splash ||
      path == AppRoutes.onboarding ||
      AppRoutes.publicPaths.contains(path)) {
    return null;
  }
  return uri.toString();
}

String _withFrom(String path, String? target) => target == null
    ? path
    : Uri(
        path: path,
        queryParameters: {AppRoutes.fromParam: target},
      ).toString();

/// Accetta solo percorsi interni, per evitare redirect verso altri siti.
String? _safe(String? target) {
  if (target == null || !target.startsWith('/') || target.startsWith('//')) {
    return null;
  }
  final path = Uri.tryParse(target)?.path;
  if (path == null ||
      path == AppRoutes.splash ||
      AppRoutes.publicPaths.contains(path)) {
    return null;
  }
  return target;
}
