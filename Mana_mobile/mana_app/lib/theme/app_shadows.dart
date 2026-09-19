import 'package:flutter/material.dart';

class AppShadows {
  // ============================================================
  // SHADOW NONE
  // Equivalente ao shadow-none
  // ============================================================

  static const List<BoxShadow> none = [];

  // ============================================================
  // SHADOW SM
  // Equivalente ao shadow-sm
  // ============================================================

  static const List<BoxShadow> sm = [
    BoxShadow(
      blurRadius: 2,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  // ============================================================
  // SHADOW DEFAULT
  // Equivalente ao shadow
  // ============================================================

  static const List<BoxShadow> base = [
    BoxShadow(
      blurRadius: 3,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  // ============================================================
  // SHADOW MD
  // Equivalente ao shadow-md
  // ============================================================

  static const List<BoxShadow> md = [
    BoxShadow(
      blurRadius: 6,
      spreadRadius: -1,
      offset: Offset(0, 4),
    ),
  ];

  // ============================================================
  // SHADOW LG
  // Equivalente ao shadow-lg
  // ============================================================

  static const List<BoxShadow> lg = [
    BoxShadow(
      blurRadius: 15,
      spreadRadius: -3,
      offset: Offset(0, 10),
    ),
  ];

  // ============================================================
  // SHADOW XL
  // Equivalente ao shadow-xl
  // ============================================================

  static const List<BoxShadow> xl = [
    BoxShadow(
      blurRadius: 25,
      spreadRadius: -5,
      offset: Offset(0, 20),
    ),
  ];

  // ============================================================
  // SHADOW 2XL
  // Equivalente ao shadow-2xl
  // ============================================================

  static const List<BoxShadow> xxl = [
    BoxShadow(
      blurRadius: 50,
      spreadRadius: -12,
      offset: Offset(0, 25),
    ),
  ];
}