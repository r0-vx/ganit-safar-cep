import 'dart:js_interop';
import '../central_client.dart' show presentationModeUri;
import 'package:web/web.dart' as web;

Future<void> browserFullscreen(bool enabled) async {
  if (enabled && web.document.fullscreenElement == null) {
    await web.document.documentElement?.requestFullscreen().toDart;
  } else if (!enabled && web.document.fullscreenElement != null) {
    await web.document.exitFullscreen().toDart;
  }
}

void browserDataMode(bool presentation) {
  web.window.location.assign(
    presentationModeUri(Uri.parse(web.window.location.href), false).toString(),
  );
}

void browserPortal(bool dashboard, bool presentation) {
  final host = dashboard
      ? 'ganit-safar-dashboard.vercel.app'
      : 'ganit-safar-smartboard.vercel.app';
  web.window.location.assign(
    presentationModeUri(Uri.https(host, '/sign-in'), false).toString(),
  );
}

void browserCleanLegacyMode() {
  final current = Uri.parse(web.window.location.href);
  if (current.queryParameters.containsKey('presentation')) {
    web.window.history.replaceState(
      null,
      '',
      presentationModeUri(current, false).toString(),
    );
  }
}
