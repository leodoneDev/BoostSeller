// Lead Empty Page : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';

class LeadEmptyScreen extends StatefulWidget {
  const LeadEmptyScreen({super.key});

  @override
  State<LeadEmptyScreen> createState() => _LeadEmptyScreenState();
}

class _LeadEmptyScreenState extends State<LeadEmptyScreen> {
  int selectedTab = 0;
  final ProfilePerformerPanelController _profilePerformerController =
      ProfilePerformerPanelController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF333333),
          appBar: AppBar(
            backgroundColor: const Color(0xFF3C3C3C),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF42A5F5),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _profilePerformerController.toggle(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset('assets/list.png', width: 24, height: 24),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Leads",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Work with leads!",
                    style: TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _buildTab("Assigned(0)", selectedTab == 0, () {
                        setState(() => selectedTab = 0);
                      }),
                      const SizedBox(width: 12),
                      _buildTab("In progress(0)", selectedTab == 1, () {
                        setState(() => selectedTab = 1);
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(height: 20),
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white54,
                            size: 100,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "There are no leads for you!",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        PerformerProfilePanel(controller: _profilePerformerController),
      ],
    );
  }

  Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF1E90FF) : const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                isSelected
                    ? [
                      const BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
