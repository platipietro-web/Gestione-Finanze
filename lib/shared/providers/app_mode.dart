import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { real, demo }

final appModeProvider = NotifierProvider<AppModeController, AppMode>(
  AppModeController.new,
);

class AppModeController extends Notifier<AppMode> {
  @override
  AppMode build() => AppMode.real;

  void enterDemo() => state = AppMode.demo;

  void exitDemo() => state = AppMode.real;
}
