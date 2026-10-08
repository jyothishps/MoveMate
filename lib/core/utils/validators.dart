import 'package:flutter/material.dart';

class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be 50 characters or less';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailPattern = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Used on the Login screen: only checks that something was typed.
  static String? passwordRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  // Used on the Register screen: Firebase needs at least 6 characters.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? boxName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a box name';
    }
    if (value.trim().length > 50) {
      return 'Box name must be 50 characters or less';
    }
    return null;
  }

  static String? location(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a location';
    }
    if (value.trim().length > 50) {
      return 'Location must be 50 characters or less';
    }
    return null;
  }

  static String? description(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Description must be 200 characters or less';
    }
    return null;
  }

  static String? itemName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an item name';
    }
    if (value.trim().length > 50) {
      return 'Item name must be 50 characters or less';
    }
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a quantity';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Quantity must be a whole number';
    }
    if (number < 1 || number > 999) {
      return 'Quantity must be between 1 and 999';
    }
    return null;
  }

  // Returns a validator that compares the text with the password field.
  static String? Function(String?) confirmPassword(
      TextEditingController passwordController,
      ) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != passwordController.text) {
        return 'Passwords do not match';
      }
      return null;
    };
  }
}