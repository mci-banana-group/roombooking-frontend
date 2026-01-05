import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, ApplicationSwitcherDescription;
import 'package:mci_booking_app/Resources/Strings.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vibration/vibration.dart';

import '../Screens/ErrorScreen.dart';

class Utils {
  static void setWebTitle(String titleName) {
    if (!kIsWeb) return;
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: titleName, primaryColor: 0xffaaaaaa),
    );
  }

  static String getLastUrlParameter(String url) {
    return url.split('/').last;
  }

  static List<String> getUrlParameters(String url) {
    url = url.replaceAll('https://', '');
    url = url.replaceAll('http://', '');
    return url.split('/');
  }

  static Future<void> vibrate({int duration = 500}) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: duration);
    }
  }

  static void showErrorScreen(BuildContext context, {String? title, String? message, Widget? widget}) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ErrorScreen(errorTitle: title, errorMessage: message, errorWidget: widget),
      ),
    );
  }

  // show error popup
  static Future<void> showErrorPopup(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Utils.mainThemeColor(context),
          title: Text(title, style: TextStyle(color: Utils.mainThemeColorI(context))),
          content: Text(message, style: TextStyle(color: Utils.mainThemeColorI(context))),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.label_button_confirm),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showInfoDialog(BuildContext context, String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Utils.mainThemeColor(context),
          title: Text(title, style: TextStyle(color: Utils.mainThemeColorI(context))),
          content: Text(message, style: TextStyle(color: Utils.mainThemeColorI(context))),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.label_button_confirm),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<String?> getTextInputDialog(
    BuildContext context,
    String title,
    String message,
    String initialValue, {
    TextInputType? keyboardType,
  }) async {
    TextEditingController controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Utils.mainThemeColor(context),
          title: Text(title, style: TextStyle(color: Utils.mainThemeColorI(context))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message, style: TextStyle(color: Utils.mainThemeColorI(context))),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 64,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.75)),
                  ),
                ),
                keyboardType: keyboardType,
                style: TextStyle(color: Utils.mainThemeColorI(context)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.label_button_confirm),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
            TextButton(
              child: Text(Strings.label_button_cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    Function? onConfirm,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Utils.mainThemeColor(context),
          title: Text(title, style: TextStyle(color: Utils.mainThemeColorI(context))),
          content: Text(message, style: TextStyle(color: Utils.mainThemeColorI(context))),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.label_button_confirm),
              onPressed: () {
                if (onConfirm != null) {
                  onConfirm();
                }
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(Strings.label_button_cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  static bool darkModeEnabled(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color mainThemeColorI(BuildContext context) {
    return mainThemeColor(context, inverse: true);
  }

  static Color mainThemeColor(BuildContext context, {bool? inverse, int? alpha}) {
    Color result;
    Brightness current = MediaQuery.of(context).platformBrightness;
    if (inverse != null && inverse) {
      if (current == Brightness.light) {
        result = ThemeData.dark().scaffoldBackgroundColor;
      } else {
        result = ThemeData.light().scaffoldBackgroundColor;
      }
    } else {
      if (current == Brightness.light) {
        result = ThemeData.light().scaffoldBackgroundColor;
      } else {
        result = ThemeData.dark().scaffoldBackgroundColor;
      }
    }
    if (alpha != null) {
      result = Color.fromARGB(alpha, result.red, result.green, result.blue);
    }
    return result;
  }

  static void redirectToURL(String url) async {}

  static void switchToURL(String url) async {
    html.window.history.pushState(null, '', url);
  }

  static Duration roundUpInitialPeriod(double minimumInitialPeriods) {
    // Guard against non‑positive values
    if (minimumInitialPeriods <= 0) {
      return const Duration();
    }

    // Convert to the next whole minute.
    final int minutes = minimumInitialPeriods.ceil();

    return Duration(minutes: minutes);
  }
}

extension ColorExtension on Color {
  Color tintWithColor(Color color, double factor) {
    return Color.lerp(this, color, factor) ?? this;
  }
}

extension StringFormatExtension on String? {
  bool isNumeric() {
    if (this == null) {
      return false;
    }
    return double.tryParse(this!) != null;
  }
}

extension FormatExtension2 on Duration? {
  String formatHM() {
    if (this == null) return '';

    final d = this!;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours ${hours == 1 ? Strings.hour_single : Strings.hour_plural}');
    if (minutes > 0) parts.add('$minutes ${minutes == 1 ? Strings.minute_single : Strings.minute_plural}');

    return parts.join(' ');
  }

  String formatHMShort() {
    if (this == null) return '';

    final d = this!;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours h');
    if (minutes > 0) parts.add('$minutes m');

    return parts.join(' ');
  }
}

extension FormatExtension on DateTime? {
  String asString({String? invalidText, bool includeSeconds = false}) {
    if (this == null) {
      return invalidText ?? "";
    }
    try {
      return DateFormat('dd.MM.yyyy HH:mm${includeSeconds ? ':ss' : ''}', 'de_AT').format(this!);
    } catch (e) {
      return invalidText ?? "";
    }
  }

  String asHourMinuteString() {
    if (this == null) {
      return "??:??";
    }
    try {
      return DateFormat('HH:mm').format(this!);
    } catch (e) {
      return "??:??";
    }
  }

  String asDateString(String? invalidText) {
    try {
      if (this == null) {
        return invalidText ?? "";
      }
      return DateFormat('dd.MM.yyyy', 'de_AT').format(this!);
    } catch (e) {
      return invalidText ?? "";
    }
  }
}
