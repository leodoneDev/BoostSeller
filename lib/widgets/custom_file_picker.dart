import 'dart:io';

import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/language_provider.dart';

class CustomFilePicker extends StatefulWidget {
  final String label;
  final String? initialFilePath;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(File file)? onFilePicked;

  const CustomFilePicker({
    super.key,
    required this.label,
    this.initialFilePath,
    this.validator,
    this.autovalidateMode,
    this.onFilePicked,
  });

  @override
  State<CustomFilePicker> createState() => _CustomFilePickerState();
}

class _CustomFilePickerState extends State<CustomFilePicker> {
  File? _pickedFile;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilePath != null && widget.initialFilePath!.isNotEmpty) {
      _pickedFile = File(widget.initialFilePath!);
    }
  }

  Future<void> _pickFile(FormFieldState<String?> state) async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _pickedFile = file;
        });
        widget.onFilePicked?.call(file);
        state.didChange(file.path);
        state.validate();
      }
    } catch (e, stack) {
      debugPrint('Error picking file: $e');
      debugPrintStack(stackTrace: stack);
      // You could show a snackbar or error message here.
    }
  }

  @override
  Widget build(BuildContext context) {
    String langCode = context.watch<LanguageProvider>().languageCode;
    return FormField<String?>(
      initialValue: _pickedFile?.path ?? widget.initialFilePath,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String?> state) {
        final borderColor =
            state.hasError
                ? Theme.of(context).colorScheme.error
                : Colors.transparent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickFile(state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _pickedFile != null
                            ? basename(_pickedFile!.path)
                            : getText("No file selected", langCode),
                        style: TextStyle(
                          color:
                              _pickedFile != null
                                  ? Colors.white
                                  : Colors.white38,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Icon(Icons.upload_file, color: Colors.white38),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 10),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
