// Lead List Page : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:boostseller/screens/lead/hostess/add_lead.dart';
import 'package:boostseller/screens/lead/hostess/lead_detail.dart';
import 'package:boostseller/screens/profile/hostess/profile_panel.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/services/api_services.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/widgets/lead_card.dart';
import 'package:boostseller/model/lead.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/services/navigation_services.dart';

class HostessDashboardScreen extends StatefulWidget {
  const HostessDashboardScreen({super.key});

  @override
  State<HostessDashboardScreen> createState() => _HostessDashboardScreenState();
}

class _HostessDashboardScreenState extends State<HostessDashboardScreen> {
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();
  bool isLoading = true; // for overlay
  List<Map<String, String>> leads = [];

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => isLoading = true);
    try {
      // Simulate backend call
      await Future.delayed(const Duration(seconds: 2));
      // Replace below with your real API logic
      leads = [
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
          "name": "Jackson",
          "interest": "Interest 1",
          "phone": "1234-1234-1235",
          "date": "26/04/2025",
          "status": "Accepted",
        },
        {
          "name": "Oliver",
          "interest": "Interest 1",
          "phone": "1234-1234-1235",
          "date": "26/04/2025",
          "status": "Accepted",
        },
        {
          "name": "Jone",
          "interest": "Interest 1",
          "phone": "1234-1234-1235",
          "date": "26/04/2025",
          "status": "Completed",
        },
        {
          "name": "Jone",
          "interest": "Interest 1",
          "phone": "1234-1234-1235",
          "date": "26/04/2025",
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
    final width = MediaQuery.of(context).size.width;

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
                padding: const EdgeInsets.all(0),
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
                  onTap: () => _profileController.toggle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.asset(
                      'assets/list.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),

            body: LoadingOverlay(
              isLoading: isLoading,
              // loadingText: "Loading data...",
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
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
                        "Please add a new lead or check previous leads",
                        style: TextStyle(
                          fontSize: Config.subTitleFontSize,
                          color: Config.subTitleFontColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: width * 0.3,
                        child: EffectButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddLeadScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Config.activeButtonColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Add Lead",
                              style: TextStyle(
                                fontSize: Config.buttonTextFontSize,
                                color: Config.buttonTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...leads.map(
                        (lead) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LeadCard(
                            lead: Lead(
                              name: lead['name']!,
                              interest: lead['interest']!,
                              phone: lead['phone']!,
                              date: lead['date']!,
                              status: lead['status']!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          ProfileHostessPanel(controller: _profileController),
        ],
      ),
    );
  }
}
