import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika input kosong, return as-is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hapus semua karakter non-digit
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Jika tidak ada digit, return empty
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format dengan thousand separator
    int value = int.parse(digitsOnly);
    String formatted = _formatter.format(value);

    // Hitung posisi cursor baru
    int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}