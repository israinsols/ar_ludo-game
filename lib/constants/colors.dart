import 'package:flutter/material.dart';

class LudoColors {
  static const Color background = Color(0xFF16162A);
  static const Color cardBg = Color(0xFF1E1E38);
  static const Color surface = Color(0xFF252545);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFF9F67FF);
  static const Color purpleDark = Color(0xFF5B21B6);
  static const Color purpleGlow = Color(0xFF7C3AED);

  static const Color red = Color(0xFFE8475F);
  static const Color green = Color(0xFF4ADE80);
  static const Color blue = Color(0xFF60A5FA);
  static const Color yellow = Color(0xFFFBBF24);

  static const Color redDim = Color(0xFF3D1520);
  static const Color greenDim = Color(0xFF153D20);
  static const Color blueDim = Color(0xFF15203D);
  static const Color yellowDim = Color(0xFF3D3515);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textMuted = Color(0xFF555577);
  static const Color border = Color(0xFF2A2A4A);

  static Color playerColor(int index) {
    switch (index) {
      case 0: return red;
      case 1: return blue;
      case 2: return green;
      case 3: return yellow;
      default: return red;
    }
  }

  static Color playerDimColor(int index) {
    switch (index) {
      case 0: return redDim;
      case 1: return blueDim;
      case 2: return greenDim;
      case 3: return yellowDim;
      default: return redDim;
    }
  }

  static String playerName(int index) {
    switch (index) {
      case 0: return 'Player 1';
      case 1: return 'Player 2';
      case 2: return 'Player 3';
      case 3: return 'Player 4';
      default: return 'Player';
    }
  }
}
