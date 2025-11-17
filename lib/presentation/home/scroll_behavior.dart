import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A custom scroll behavior that enables scrolling with a mouse and trackpad,
/// which is useful for desktop and web platforms.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}