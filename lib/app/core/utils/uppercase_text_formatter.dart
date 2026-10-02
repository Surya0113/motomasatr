import 'package:flutter/services.dart';

class UppercaseTextFormatter extends TextInputFormatter {
  const UppercaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final uppercasedText = newValue.text.toUpperCase();

    return newValue.copyWith(
      text: uppercasedText,
      selection: TextSelection.collapsed(
        offset: uppercasedText.length < newValue.selection.end
            ? uppercasedText.length
            : newValue.selection.end,
      ),
      composing: TextRange.empty,
    );
  }
}
