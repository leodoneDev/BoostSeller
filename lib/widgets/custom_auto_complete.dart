import 'package:flutter/material.dart';

class EmailAutocompleteField extends StatefulWidget {
  final Future<List<String>> Function() fetchSuggestions;
  final void Function(String)? onSelected;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType keyboardType;

  const EmailAutocompleteField({
    super.key,
    required this.fetchSuggestions,
    this.onSelected,
    this.controller,
    this.hint,
    this.keyboardType = TextInputType.emailAddress,
  });

  @override
  _EmailAutocompleteFieldState createState() => _EmailAutocompleteFieldState();
}

class _EmailAutocompleteFieldState extends State<EmailAutocompleteField> {
  List<String> _suggestions = [];
  bool _loaded = false;

  Future<void> _loadSuggestions() async {
    if (_loaded) return;
    _suggestions = await widget.fetchSuggestions();
    _loaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        _loadSuggestions(); // Fetch once on use
        if (textEditingValue.text.isEmpty || _suggestions.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _suggestions.where(
          (email) => email.toLowerCase().startsWith(
            textEditingValue.text.toLowerCase(),
          ),
        );
      },
      onSelected: widget.onSelected ?? (_) {},
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextField(
          controller: widget.controller ?? textEditingController,
          focusNode: focusNode,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Enter email',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
