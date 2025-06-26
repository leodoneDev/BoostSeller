// Dynamic field reusable component : made by Leo on 2025/05/20

import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/widgets/custom_input_text.dart';
import 'package:boostseller/widgets/custom_dropdown_normal.dart';
import 'package:boostseller/widgets/custom_currency_input.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/custom_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:boostseller/widgets/custom_image_picker.dart';
import 'package:boostseller/widgets/custom_file_picker.dart';
import 'dart:io';
import 'package:boostseller/widgets/custom_comment.dart';
import 'package:boostseller/widgets/custom_camera_capture.dart';
import 'package:boostseller/widgets/custom_toggle.dart';
import 'package:boostseller/widgets/custom_checkbox_group.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/language_provider.dart';

class DynamicField extends StatefulWidget {
  final Map<String, dynamic> field;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(File file)? onImagePicked;
  final void Function(File file)? onFilePicked;
  final void Function(File file)? onImageCaptured;
  final String label;
  final List<dynamic> items;

  const DynamicField({
    super.key,
    required this.field,
    this.controller,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.onImagePicked,
    this.onFilePicked,
    this.onImageCaptured,
    required this.label,
    required this.items,
  });

  @override
  State<DynamicField> createState() => _DynamicFieldState();
}

class _DynamicFieldState extends State<DynamicField> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DynamicField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String label = widget.label;
    final String type = widget.field['type'];
    final List<String> options = (widget.items as List?)?.cast<String>() ?? [];
    String langCode = context.watch<LanguageProvider>().languageCode;
    switch (type) {
      case 'input':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomLabel(label: label),
            const SizedBox(height: 6),
            CustomTextField(
              controller: widget.controller ?? TextEditingController(),
              focusNode: widget.focusNode,
              hint: label,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
            ),
            const SizedBox(height: 12),
          ],
        );

      case 'number':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomLabel(label: label),
            const SizedBox(height: 6),
            CustomTextField(
              controller: widget.controller ?? TextEditingController(),
              focusNode: widget.focusNode,
              hint: label,
              keyboardType: TextInputType.number,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
            ),
            const SizedBox(height: 12),
          ],
        );

      case 'currency':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomLabel(label: label),
            const SizedBox(height: 6),
            CustomCurrencyInput(
              label: label,
              hintText: getText("currency_comment", langCode),
              controller: widget.controller ?? TextEditingController(),
              focusNode: widget.focusNode,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
            ),
            const SizedBox(height: 12),
          ],
        );

      case 'dropdown':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomLabel(label: label),
            const SizedBox(height: 6),
            CustomDropdownNormal(
              hint: label,
              value:
                  widget.controller?.text.isEmpty == true
                      ? null
                      : widget.controller?.text,
              items: options, // should be List<Map<String, dynamic>>
              onChanged: (value) {
                if (widget.controller != null && value != null) {
                  widget.controller!.text = value;
                }
              },
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
            ),
            const SizedBox(height: 12),
          ],
        );

      case 'checkbox':
        final bool isSelected = widget.controller?.text == 'true';
        if (widget.controller != null && widget.controller!.text.isEmpty) {
          widget.controller!.text = 'false';
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                if (widget.controller != null) {
                  widget.controller!.text = (!isSelected).toString();
                  setState(() {}); // Update UI
                }
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (checked) {
                        if (widget.controller != null) {
                          widget.controller!.text =
                              (checked ?? false).toString();
                          setState(() {});
                        }
                      },
                      activeColor: Config.activeButtonColor,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        );

      case 'date':
        DateTime? selectedDate;
        if (widget.controller?.text.isNotEmpty ?? false) {
          selectedDate = DateTime.tryParse(widget.controller!.text);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomLabel(label: label),
            const SizedBox(height: 6),
            CustomDatePicker(
              label: label,
              hintText: getText("date_comment", langCode),
              initialDate: selectedDate,
              focusNode: widget.focusNode,
              onDateSelected: (date) {
                if (date != null && widget.controller != null) {
                  widget.controller!.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(date);
                }
              },
              validator: (date) {
                if (date == null) {
                  return getText(
                    "{label} is required",
                    args: {'label': label},
                    langCode,
                  );
                }
                return null;
              },
              autovalidateMode: widget.autovalidateMode,
            ),
            const SizedBox(height: 12),
          ],
        );

      case 'photo':
        return CustomImagePicker(
          label: label,
          controller: widget.controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return getText("photo_required", langCode);
            }
            return null;
          },
          onImagePicked: (file) {
            widget.onImagePicked?.call(file);
          },
        );

      case 'file':
        return CustomFilePicker(
          label: label,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return getText("file_required", langCode);
            }
            return null;
          },
          onFilePicked: (file) {
            widget.onImagePicked?.call(file);
          },
        );

      case 'comment':
        return CustomMultilineTextField(
          label: label,
          hintText: getText("comment_hint", langCode),
          controller: widget.controller ?? TextEditingController(),
          focusNode: widget.focusNode,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
        );

      case 'camera':
        return CameraCaptureField(
          label: label,
          validator: (file) => file == null ? '$label is required' : null,
          onImageCaptured: (file) {
            print('image captured: ${file.path}');
            widget.onImagePicked?.call(file);
          },
        );

      case 'toggle':
        final bool isSelected = widget.controller?.text == 'true';
        if (widget.controller != null && widget.controller!.text.isEmpty) {
          widget.controller!.text = 'false';
        }
        return CustomToggleField(
          label: label,
          initialValue: isSelected,
          onChanged: (value) {
            if (widget.controller != null) {
              widget.controller!.text = (value).toString();
            }
          },
        );

      case 'checkbox group':
        final items = List<String>.from(options);
        return CheckboxGroup(
          label: label,
          options: items,
          controller: widget.controller ?? TextEditingController(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return getText("checkbox_group_required", langCode);
            }
            return null;
          },
        );

      default:
        return const SizedBox.shrink(); // Skip unknown types
    }
  }
}
