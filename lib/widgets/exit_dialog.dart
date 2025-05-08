import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/services/navigation_services.dart';

class ExitDialog {
  static Future<void> show() async {
    final context =
        NavigationService.navigatorKey.currentState?.overlay?.context;

    if (context == null) {
      debugPrint('Cannot show exit dialog: context is null');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.exit_to_app, size: 50, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Exit App?',
                  style: TextStyle(
                    fontSize: Config.titleFontSize,
                    color: Config.titleFontColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Do you really want to close the application?',
                  style: TextStyle(
                    fontSize: Config.subTitleFontSize,
                    color: Config.subTitleFontColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dialogButton(
                      context,
                      label: 'Cancel',
                      color: Config.activeButtonColor,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    _dialogButton(
                      context,
                      label: 'Exit',
                      color: Config.stressColor,
                      onPressed: () => SystemNavigator.pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _dialogButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return EffectButton(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: Config.buttonTextFontSize,
            color: Config.buttonTextColor,
          ),
        ),
      ),
    );
  }
}
