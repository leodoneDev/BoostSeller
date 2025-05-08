import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:boostseller/services/navigation_services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ToastUtil {
  static bool _isToastVisible = false;

  static void success(String message) {
    _showToast(message, isError: false);
  }

  static void error(String message) {
    _showToast(message, isError: true);
  }

  static void _showToast(String message, {bool isError = false}) {
    if (_isToastVisible) return;
    _isToastVisible = true;

    final context =
        NavigationService.navigatorKey.currentState?.overlay?.context;
    if (context == null) {
      _isToastVisible = false;
      return;
    }

    DelightToastBar(
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            // width: MediaQuery.of(context).size.width * 0.9,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isError ? Colors.redAccent : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error : Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 2),
    ).show(context);

    // Manually reset the flag after the duration
    Future.delayed(const Duration(seconds: 2), () {
      _isToastVisible = false;
    });
  }
}
