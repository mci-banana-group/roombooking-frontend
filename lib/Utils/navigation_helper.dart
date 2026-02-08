import 'package:flutter/material.dart';
import '../Constants/layout_constants.dart';

class NavigationHelper {
  /// Returns a Route that uses no animation on desktop (>= kMobileBreakpoint)
  /// and the standard platform transition on mobile.
  static Route<T> getRoute<T>(BuildContext context, Widget page) {
    bool isDesktop = MediaQuery.of(context).size.width >= LayoutConstants.kMobileBreakpoint;

    if (isDesktop) {
      return PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    } else {
      return MaterialPageRoute<T>(builder: (context) => page);
    }
  }
}
