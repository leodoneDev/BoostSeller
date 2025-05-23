// Lead Detail Page : made by Leo on 2025/05/04

import 'package:boostseller/widgets/button_effect.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/hostess/profile_panel.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/model/lead.dart';

class HostessLeadDetailScreen extends StatefulWidget {
  const HostessLeadDetailScreen({super.key});

  @override
  State<HostessLeadDetailScreen> createState() =>
      _HostessLeadDetailScreenState();
}

class _HostessLeadDetailScreenState extends State<HostessLeadDetailScreen> {
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Lead lead = args['lead'] as Lead;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
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
                  child: Image.asset('assets/list.png', width: 24, height: 24),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    "Lead Detail",
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Config.leadDetailBackroudColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lead.name,
                              style: TextStyle(
                                fontSize: Config.leadNameFontSize,
                                fontWeight: FontWeight.bold,
                                color: Config.leadNameColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(lead.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                lead.status,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(
                          color: Config.leadDivederColor,
                          height: 20,
                        ),
                        _buildDetailRow("Phone", lead.phone),
                        _buildDetailRow("Interest", lead.interest),
                        _buildDetailRow("Register ID", "1234-1234-1234"),
                        _buildDetailRow("Register Date", lead.date),

                        if (_showMore) ...[
                          _buildDetailRow("Gender", "Male"),
                          _buildDetailRow("Age", "38"),
                          _buildDetailRow("Budget", "\$500"),
                        ],

                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() => _showMore = !_showMore);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _showMore ? "less ..." : "more ...",
                              style: const TextStyle(
                                fontSize: Config.leadTextFontSize,
                                color: Colors.white60,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),

        /// ✅ Profile Toggle Panel (overlays everything)
        ProfileHostessPanel(controller: _profileController),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: "$label : ",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'assigned':
      return Colors.blue;
    case 'presentation':
      return Colors.indigo;
    case 'test drive':
      return Colors.indigo;
    case 'closed':
      return Colors.red;
    case 'completed':
      return Colors.green;
    case 'accepted':
      return Colors.indigo;
    default:
      return Colors.grey;
  }
}
