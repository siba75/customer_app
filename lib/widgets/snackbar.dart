import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.blue,
  Color textColor = Colors.white,
  IconData? icon,
}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        if (icon != null) Icon(icon, color: textColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.tr(message),
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.all(16),
    action: SnackBarAction(
      label: context.tr('موافق'),
      textColor: Colors.amberAccent,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
