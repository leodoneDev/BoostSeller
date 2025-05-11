import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:boostseller/services/navigation_services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ToastUtil {
  static bool _isToastVisible = false;

  static void success(String message) {
    _showToast(message, 'success');
  }

  static void error(String message) {
    _showToast(message, 'error');
  }

  static void info(String message) {
    _showToast(message, 'info');
  }

  static void notification(String message) {
    _showToast(message, 'notification');
  }

  static void _showToast(String message, String type) {
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
                color: _getTypeColor(type),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _getTypeIcon(type),
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

Color _getTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'error':
      return Colors.red;
    case 'success':
      return Colors.green;
    case 'info':
      return Colors.blue;
    case 'notification':
      return Colors.yellow;
    default:
      return Colors.grey;
  }
}

Icon _getTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'error':
      return Icon(Icons.error, color: Colors.white);
    case 'success':
      return Icon(Icons.check_circle, color: Colors.white); {}
    case 'info':
      return Icon(Icons.info, color: Colors.white);
    case 'notification':
      return Icon(Icons.notifications, color: Colors.white);
    default:
      return Icon(Icons.width_normal, color: Colors.white);
  }
}
