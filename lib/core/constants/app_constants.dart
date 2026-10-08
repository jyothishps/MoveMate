import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'MoveMate';
  static const String tagline = 'Pack smart. Find fast.';

  /// Categories offered when creating a box.
  static const List<String> boxCategories = [
    'Kitchen',
    'Bedroom',
    'Living Room',
    'Bathroom',
    'Clothing',
    'Books',
    'Electronics',
    'Documents',
    'Tools',
    'Office',
    'Miscellaneous',
  ];

  /// Maps category to a recognizable room/category icon
  static IconData categoryIcon(String category) {
    switch (category.toLowerCase().trim()) {
      case 'kitchen':
        return Icons.soup_kitchen_outlined;
      case 'bedroom':
        return Icons.bed_outlined;
      case 'living room':
        return Icons.weekend_outlined;
      case 'bathroom':
        return Icons.bathtub_outlined;
      case 'clothing':
        return Icons.checkroom_outlined;
      case 'books':
        return Icons.menu_book_outlined;
      case 'electronics':
        return Icons.devices_other_outlined;
      case 'documents':
        return Icons.folder_outlined;
      case 'tools':
        return Icons.build_outlined;
      case 'office':
        return Icons.work_outline;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}