import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:provider/provider.dart';

class CameraCaptureField extends StatefulWidget {
  final String label;
  final bool required;
  final void Function(File file)? onImageCaptured;
  final String? Function(File?)? validator;
  final AutovalidateMode? autovalidateMode;

  const CameraCaptureField({
    super.key,
    required this.label,
    this.required = false,
    this.onImageCaptured,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<CameraCaptureField> createState() => _CameraCaptureFieldState();
}

class _CameraCaptureFieldState extends State<CameraCaptureField> {
  File? _imageFile;

  Future<void> _captureImage(FormFieldState<File?> state) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked != null) {
      final image = File(picked.path);
      setState(() {
        _imageFile = image;
      });
      widget.onImageCaptured?.call(image);
      state.didChange(image);
      state.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    String langCode = context.watch<LanguageProvider>().languageCode;
    return FormField<File?>(
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (state) {
        final hasError = state.hasError;
        final borderColor =
            hasError ? Theme.of(context).colorScheme.error : Colors.transparent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 6),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.label,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    if (widget.required)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),

            // Capture area
            GestureDetector(
              onTap: () => _captureImage(state),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child:
                    _imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white38,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                getText("Tap to capture", langCode),
                                style: TextStyle(color: Colors.white38),
                              ),
                            ],
                          ),
                        ),
              ),
            ),

            // Error text
            if (hasError)
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
