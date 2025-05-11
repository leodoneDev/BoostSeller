// // Lead List Page : made by Leo on 2025/05/04

import 'package:boostseller/widgets/button_effect.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/lead_card.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/model/lead.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:boostseller/services/navigation_services.dart';

class PerformerDashboardScreen extends StatefulWidget {
  const PerformerDashboardScreen({super.key});

  @override
  State<PerformerDashboardScreen> createState() =>
      _PerformerDashboardScreenState();
}

class _PerformerDashboardScreenState extends State<PerformerDashboardScreen> {
  int selectedTab = 0;
  bool isLoading = true; // for overlay
  List<Map<String, String>> assignedLeads = [];
  List<Map<String, String>> acceptedLeads = [];
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    setState(() => isLoading = true);
    try {
      // Simulate backend call
      await Future.delayed(const Duration(seconds: 2));
      // Replace below with your real API logic
      assignedLeads = [
        {
          "name": "Maxim",
          "interest": "Interest 2",
          "phone": "1234-1234-1235",
          "date": "25/04/2025",
          "status": "Assigned",
        },
        {
          "name": "Tom",
          "interest": "Interest 1",
          "phone": "1234-1234-1235",
          "date": "26/04/2025",
          "status": "Assigned",
        },
        {
          "name": "Jone",
          "interest": "Interest 1",
          "phone": "1234-1234-1235",
          "date": "26/04/2025",
          "status": "Assigned",
        },
      ];
      acceptedLeads = [
        {
          "name": "Oleh",
          "interest": "Interest 1",
          "phone": "1234-1234-1235",
          "date": "27/04/2025",
          "status": "Presentation",
        },
        {
          "name": "John",
          "interest": "Interest 3",
          "phone": "1234-1234-1235",
          "date": "28/04/2025",
          "status": "Completed",
        },
        {
          "name": "Maxim",
          "interest": "Interest 2",
          "phone": "1234-1234-1235",
          "date": "28/04/2025",
          "status": "Test Drive",
        },
        {
          "name": "Tom",
          "interest": "Interest 3",
          "phone": "1234-1234-1235",
          "date": "28/04/2025",
          "status": "Closed",
        },
      ];
    } catch (e) {
      ToastUtil.error("Failed to load leads");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BackOverrideWrapper(
      onBack: () async {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('auth_token')?.toLowerCase() ?? '';
        if (role.isNotEmpty) {
          await ExitDialog.show();
        } else {
          NavigationService.pushReplacementNamed('/onboarding');
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Config.backgroundColor,
            appBar: AppBar(
              backgroundColor: Config.appbarColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final role =
                      prefs.getString('auth_token')?.toLowerCase() ?? '';
                  if (role.isNotEmpty) {
                    await ExitDialog.show();
                  } else {
                    NavigationService.pushReplacementNamed('/onboarding');
                  }
                },
                icon: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Config.activeButtonColor,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 14,
                    color: Config.iconDefaultColor,
                  ),
                ),
              ),
              actions: [
                EffectButton(
                  onTap: () {
                    NavigationService.pushNamed('/notifications');
                  },
                  child: const Icon(
                    Icons.notifications,
                    size: 35,
                    color: Config.containerColor,
                  ),
                ),

                EffectButton(
                  onTap: () {
                    _profileController.toggle();
                  },
                  child: const Icon(
                    Icons.account_circle,
                    size: 35,
                    color: Config.containerColor,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: LoadingOverlay(
              isLoading: isLoading,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Leads",
                        style: TextStyle(
                          fontSize: Config.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Config.titleFontColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Work with leads!",
                        style: TextStyle(
                          fontSize: Config.subTitleFontSize,
                          color: Config.subTitleFontColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tabs
                      Row(
                        children: [
                          _buildTab(
                            "Assigned(${assignedLeads.length})",
                            selectedTab == 0,
                            () {
                              setState(() => selectedTab = 0);
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildTab(
                            "Accepted(${acceptedLeads.length})",
                            selectedTab == 1,
                            () {
                              setState(() => selectedTab = 1);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              selectedTab == 0
                                  ? assignedLeads.length
                                  : acceptedLeads.length,
                          itemBuilder: (context, index) {
                            final lead =
                                selectedTab == 0
                                    ? assignedLeads[index]
                                    : acceptedLeads[index];
                            return LeadCard(
                              role: 'performer',
                              lead: Lead(
                                name: lead['name']!,
                                interest: lead['interest']!,
                                phone: lead['phone']!,
                                date: lead['date']!,
                                status: lead['status']!,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Toggleable Profile Panel
          PerformerProfilePanel(controller: _profileController),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: EffectButton(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected ? Config.activeButtonColor : Config.deactiveTabColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Config.buttonTextColor,
                fontSize: Config.buttonTextFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
