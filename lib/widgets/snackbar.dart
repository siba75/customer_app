import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.blue, Color textColor = Colors.white, IconData? icon}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        if (icon != null) Icon(icon, color: textColor), // إذا كان هناك أيقونة، سيتم عرضها
        SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(color: textColor))),
      ],
    ),
    backgroundColor: backgroundColor, // لون خلفية
    duration: Duration(seconds: 3), // مدة عرض الـSnackBar
    behavior: SnackBarBehavior.floating, // طريقة عرض الـSnackBar
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // حواف دائرية
    ),
    margin: EdgeInsets.all(16), // المسافة حول الـSnackBar
    action: SnackBarAction(
      label: 'موافق', // زر تفاعل
      textColor: Colors.amberAccent,
      onPressed: () {
        // إضافة أكشن عند الضغط على الزر
      },
    ),
  );

  // عرض الـSnackBar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}