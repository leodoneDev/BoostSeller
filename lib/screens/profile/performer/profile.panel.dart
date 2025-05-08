// Performer Profile Panel Page : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/screens/auth/login.dart';
import 'package:boostseller/constants.dart';

class ProfilePerformerPanelController extends ChangeNotifier {
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

class PerformerProfilePanel extends StatelessWidget {
  final ProfilePerformerPanelController controller;

  const PerformerProfilePanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isVisible) return const SizedBox.shrink();

        return Stack(
          children: [
            // Tap outside to close
            GestureDetector(
              onTap: controller.toggle,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withAlpha(102),
              ),
            ),

            // Side panel
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.white,
                                    backgroundImage: AssetImage(
                                      'assets/profile.jpg',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.home,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Maxim",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "1-232-234-2345",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Performer",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),

                              const Divider(color: Colors.white24),
                              const SizedBox(height: 10),
                              const Text(
                                "Score",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _scoreRow("Conversion", "60%"),
                              _scoreRow("Responsiveness", "0.7"),
                              _scoreRow("Effectiveness", "72"),

                              const Divider(color: Colors.white24),
                              const SizedBox(height: 10),
                              const Text(
                                "Leads",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _scoreRow("Total", "7"),
                              _scoreRow("Assigned", "3"),
                              _scoreRow("In progress", "4"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('auth_token');
                            controller.close();
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
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Config.activeButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _scoreRow(String label, String value) {
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
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
