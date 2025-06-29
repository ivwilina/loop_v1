import 'package:flutter/material.dart';
import 'package:loop_application/theme/theme.dart';

class TextInputField extends StatelessWidget {
  final String placeholderLabel;
  const TextInputField({super.key, required this.placeholderLabel});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: normalText,
      decoration: InputDecoration(
        label: Text(placeholderLabel, style: normalText),
        alignLabelWithHint: true,
        floatingLabelStyle: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
      ),
    );
  }
}
