
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(File file)? onImagePicked;

  const CustomImagePicker({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.autovalidateMode,
    this.onImagePicked,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  File? _imageFile;

  Future<void> _pickImage(FormFieldState<String?> state) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _imageFile = file;
      });

      widget.controller?.text = pickedFile.path;
      widget.onImagePicked?.call(file);
      state.didChange(pickedFile.path);
      state.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = 150;

    return FormField<String?>(
      initialValue: widget.controller?.text,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String?> state) {
        final hasError = state.hasError;
        final borderColor =
            hasError ? Theme.of(context).colorScheme.error : Colors.transparent;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 6),
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(state),
                child: Container(
                  width: imageSize,
                  height: imageSize,
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
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white38,
                              size: 32,
                            ),
                          ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Center(
                  child: Text(
                    state.errorText ?? '',
                    style:
                        Theme.of(context).inputDecorationTheme.errorStyle ??
                        TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
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
