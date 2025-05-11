import 'package:flutter/material.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/model/lead.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/screens/lead/performer/detail/presentation_lead_detail.dart';
import 'package:boostseller/screens/lead/performer/detail/testdrive_lead_detail.dart';

class LeadCard extends StatelessWidget {
  final String role;
  final Lead lead;

  const LeadCard({super.key, required this.role, required this.lead});

  @override
  Widget build(BuildContext context) {
    return EffectButton(
      onTap: () {
        if (role == 'performer') {
          if (lead.status == "Assigned") {
            NavigationService.pushNamed(
              '/performer-assigned-lead-detail',
              arguments: {'lead': lead},
            );
          } else if (lead.status == "Presentation") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PresentationLeadDetailScreen(),
              ),
            );
          } else if (lead.status == "Test Drive") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TestDriveLeadDetailScreen(),
              ),
            );
          } else if (lead.status == "Completed") {
            ToastUtil.success("Developing...");
          } else if (lead.status == "Closed") {
            ToastUtil.success("Developing...");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Unknown status: ${lead.status}")),
            );
          }
        } else {
          NavigationService.pushNamed(
            '/hostess-lead-detail',
            arguments: {'lead': lead},
          );
        }
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
                  lead.name,
                  style: const TextStyle(
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(lead.interest, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lead.status,
                  style: const TextStyle(color: Colors.white60),
                ),
                Text(lead.date, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ],
        ),
      ),
    );
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
}
