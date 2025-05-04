// Lead List Page : made by Leo on 2025/05/04

import 'package:boostseller/widgets/button.effect.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile.panel.dart';
import 'package:boostseller/screens/lead/performer/lead.detail.dart';
import 'package:boostseller/constants.dart';

class LeadAssignedScreen extends StatefulWidget {
  const LeadAssignedScreen({super.key});

  @override
  State<LeadAssignedScreen> createState() => _LeadAssignedScreenState();
}

class _LeadAssignedScreenState extends State<LeadAssignedScreen> {
  int selectedTab = 0;
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
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
                  padding: const EdgeInsets.only(right: 12),
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
                      _buildTab("Assigned(1)", selectedTab == 0, () {
                        setState(() => selectedTab = 0);
                      }),
                      const SizedBox(width: 12),
                      _buildTab("In progress(2)", selectedTab == 1, () {
                        setState(() => selectedTab = 1);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (selectedTab == 0) ...[
                    _buildLeadCard(
                      name: "Maxim",
                      interest: "Interest 2",
                      phone: "1234-1234-1235",
                      date: "25/04/2025",
                      status: "Assigned",
                    ),
                  ] else ...[
                    _buildLeadCard(
                      name: "Oleh",
                      interest: "Interest 1",
                      phone: "1234-1234-1234",
                      date: "28/04/2025",
                      status: "Presentation",
                    ),
                    const SizedBox(height: 12),
                    _buildLeadCard(
                      name: "Maxim",
                      interest: "Interest 2",
                      phone: "1234-1234-1235",
                      date: "25/04/2025",
                      status: "Test Drive",
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        /// Toggleable Profile Panel
        PerformerProfilePanel(controller: _profileController),
      ],
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

  Widget _buildLeadCard({
    required String name,
    required String interest,
    required String phone,
    required String date,
    required String status,
  }) {
    return EffectButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    LeadDetailScreen(status: status), // <-- Your detail page
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Config.leadCardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: Config.leadNameFontSize,
                    fontWeight: FontWeight.bold,
                    color: Config.leadNameColor,
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: Config.leadTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: Config.leadTextFontSizeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(interest, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(phone, style: const TextStyle(color: Colors.white60)),
                Text(date, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
