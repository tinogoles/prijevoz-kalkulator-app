// lib/screens/lokacije_autocomplete_widget.dart
import 'package:flutter/material.dart';

class LokacijeAutocompleteWidget extends StatefulWidget {
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
  State<LokacijeAutocompleteWidget> createState() => _LokacijeAutocompleteWidgetState();
}

class _LokacijeAutocompleteWidgetState extends State<LokacijeAutocompleteWidget> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['display_name'] ?? '',
      optionsBuilder: (TextEditingValue textEditingValue) async {
        return await widget.onSuggestionsFetch(textEditingValue.text);
      },
      onSelected: (Map<String, dynamic> selection) {
        widget.controller.text = selection['display_name'] ?? '';
        widget.onSelected(selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onEditingComplete) {
        // Sigurna sinkronizacija bez skakanja kursora i blokiranja tipkanja
        if (textEditingController.text != widget.controller.text) {
          textEditingController.text = widget.controller.text;
          textEditingController.selection = TextSelection.fromPosition(
            TextPosition(offset: textEditingController.text.length),
          );
        }

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (val) {
            widget.controller.text = val;
            widget.onChanged(val);
            if (widget.onClearedCoords != null) widget.onClearedCoords!();
          },
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on),
          ),
          onEditingComplete: onEditingComplete,
        );
      },
    );
  }
}
