import 'package:flutter/material.dart';

class LokacijeAutocompleteWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Future<List<Map<String, dynamic>>> Function(String) onSuggestionsFetch;
  final ValueChanged<Map<String, dynamic>> onSelected;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClearedCoords;

  const LokacijeAutocompleteWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.onSuggestionsFetch,
    required this.onSelected,
    required this.onChanged,
    this.onClearedCoords,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['display_name'] ?? '',
      optionsBuilder: (TextEditingValue textEditingValue) async {
        return await onSuggestionsFetch(textEditingValue.text);
      },
      onSelected: (Map<String, dynamic> selection) {
        onSelected(selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onEditingComplete) {
        if (textEditingController.text.isEmpty && controller.text.isNotEmpty) {
          textEditingController.text = controller.text;
        }

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (val) {
            controller.text = val;
            onChanged(val);
            if (onClearedCoords != null) onClearedCoords!();
          },
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on),
          ),
          onEditingComplete: onEditingComplete,
        );
      },
    );
  }
}
