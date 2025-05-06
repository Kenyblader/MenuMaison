import 'package:flutter/material.dart';

const Color tealColor = Color(0xFF26A69A);
const Color whiteColor = Colors.white;
const Color greyColor = Colors.grey;

ThemeData appTheme = ThemeData(
  primaryColor: tealColor,
  scaffoldBackgroundColor: whiteColor,
  fontFamily: 'Poppins',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
    headlineSmall: TextStyle(
        color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  cardTheme: const CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: tealColor),
    ),
    labelStyle: const TextStyle(color: Colors.black54),
  ),
);
