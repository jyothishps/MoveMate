import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const List<Color> primaryGradient = [
    Color(0xFF3B82F6),
    Color(0xFF1D4ED8),
  ];

  // Canvas & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Category Accent Colors (purely for UI visual distinction)
  static const Color catKitchen = Color(0xFFEA580C);
  static const Color catKitchenLight = Color(0xFFFFEDD5);

  static const Color catBedroom = Color(0xFF6366F1);
  static const Color catBedroomLight = Color(0xFFEEF2FF);

  static const Color catLivingRoom = Color(0xFF0D9488);
  static const Color catLivingRoomLight = Color(0xFFCCFBF1);

  static const Color catBathroom = Color(0xFF0284C7);
  static const Color catBathroomLight = Color(0xFFE0F2FE);

  static const Color catClothing = Color(0xFFC026D3);
  static const Color catClothingLight = Color(0xFFFAE8FF);

  static const Color catBooks = Color(0xFFCA8A04);
  static const Color catBooksLight = Color(0xFFFEF9C3);

  static const Color catElectronics = Color(0xFFE11D48);
  static const Color catElectronicsLight = Color(0xFFFFE4E6);

  static const Color catDocuments = Color(0xFF475569);
  static const Color catDocumentsLight = Color(0xFFF1F5F9);

  static const Color catTools = Color(0xFF4F46E5);
  static const Color catToolsLight = Color(0xFFEEF2FF);

  static const Color catOffice = Color(0xFF2563EB);
  static const Color catOfficeLight = Color(0xFFDBEAFE);

  static const Color catMisc = Color(0xFF64748B);
  static const Color catMiscLight = Color(0xFFF1F5F9);

  /// Helper to get category accent color
  static Color categoryColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'kitchen':
        return catKitchen;
      case 'bedroom':
        return catBedroom;
      case 'living room':
        return catLivingRoom;
      case 'bathroom':
        return catBathroom;
      case 'clothing':
        return catClothing;
      case 'books':
        return catBooks;
      case 'electronics':
        return catElectronics;
      case 'documents':
        return catDocuments;
      case 'tools':
        return catTools;
      case 'office':
        return catOffice;
      default:
        return catMisc;
    }
  }

  /// Helper to get category soft pastel background color
  static Color categoryLightColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'kitchen':
        return catKitchenLight;
      case 'bedroom':
        return catBedroomLight;
      case 'living room':
        return catLivingRoomLight;
      case 'bathroom':
        return catBathroomLight;
      case 'clothing':
        return catClothingLight;
      case 'books':
        return catBooksLight;
      case 'electronics':
        return catElectronicsLight;
      case 'documents':
        return catDocumentsLight;
      case 'tools':
        return catToolsLight;
      case 'office':
        return catOfficeLight;
      default:
        return catMiscLight;
    }
  }
}