// System back event interrupt library : made by Leo on 2025/05/06

import 'package:flutter/material.dart';

class BackOverrideWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onBack;

  const BackOverrideWrapper({
    super.key,
    required this.child,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onBack(); // Custom action
        return false; // Prevent default back navigation
      },
      child: child,
    );
  }
}
