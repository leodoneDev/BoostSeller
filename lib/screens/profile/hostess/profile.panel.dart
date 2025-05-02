// Hostess Profile Panel Page : made by Leo on 2025/05/01

import 'package:flutter/material.dart';

class ProfileHostessPanelController extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void close() {
    _isVisible = false;
    notifyListeners();
  }
}

class ProfileHostessPanel extends StatelessWidget {
  final ProfileHostessPanelController controller;

  const ProfileHostessPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isVisible) return const SizedBox.shrink();

        return Stack(
          children: [
            // ✅ Tap outside to close
            GestureDetector(
              onTap: controller.toggle,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withAlpha(102),
              ),
            ),

            // ✅ Right-side panel
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Material(
                color: const Color(0xFF2C2C2C),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFF42A5F5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const ListTile(
                          leading: Icon(Icons.home, color: Colors.white),
                          title: Text(
                            "Maxim",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const ListTile(
                          leading: Icon(Icons.phone, color: Colors.white),
                          title: Text(
                            "1-232-234-2345",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const ListTile(
                          leading: Icon(Icons.check, color: Colors.white),
                          title: Text(
                            "Hostess",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Divider(color: Colors.white24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Leads",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _stat("Total", 15),
                        _stat("Pending", 3),
                        _stat("Assigned", 8),
                        _stat("Closed", 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _stat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label :",
              style: const TextStyle(color: Colors.white60),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text("$value", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
