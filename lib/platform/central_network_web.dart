import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Stream<bool> centralNetworkChanges() {
  late StreamController<bool> controller;
  final onOnline = ((web.Event event) => controller.add(true)).toJS;
  final onOffline = ((web.Event event) => controller.add(false)).toJS;
  controller = StreamController<bool>(
    onListen: () {
      web.window.addEventListener('online', onOnline);
      web.window.addEventListener('offline', onOffline);
      controller.add(web.window.navigator.onLine);
    },
    onCancel: () {
      web.window.removeEventListener('online', onOnline);
      web.window.removeEventListener('offline', onOffline);
    },
  );
  return controller.stream;
}
