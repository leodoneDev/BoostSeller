// Hostess Profile Panel Page : made by Leo on 2025/05/01

import 'package:flutter/material.dart';
import 'package:boostseller/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/screens/auth/login.dart';

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
            // Overlay background
            GestureDetector(
              onTap: controller.toggle,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withAlpha(102),
              ),
            ),

            // Sliding panel
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
                child: Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              const Center(
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage(
                                    'assets/profile.jpg',
                                  ), // Replace with your image
                                ),
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(Icons.home, "Maxim"),
                                  const SizedBox(height: 10),
                                  _infoRow(Icons.phone, "1-232-234-2345"),
                                  const SizedBox(height: 10),
                                  _infoRow(Icons.check, "Hostess"),
                                ],
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

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Config.activeButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('auth_token');
                            // controller.close();
                            // Navigator.of(context).pushAndRemoveUntil(
                            //   MaterialPageRoute(
                            //     builder: (_) => const LoginScreen(),
                            //   ),
                            //   (route) => false,
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
