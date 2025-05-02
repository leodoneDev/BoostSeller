import 'package:flutter/material.dart';
import './add.lead.dart';
import './lead.detail.dart';
import 'package:boostseller/screens/profile/hostess/profile.panel.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF333333),
          appBar: AppBar(
            backgroundColor: const Color(0xFF3C3C3C),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(0),
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
                onTap: () => _profileController.toggle(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset('assets/list.png', width: 24, height: 24),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
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
                    "Please add a new lead or check previous leads",
                    style: TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                  const SizedBox(height: 20),

                  // Add Lead Button
                  SizedBox(
                    width: width * 0.3,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddLeadScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Add Lead",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLeadCard(
                    context,
                    name: "Oleh",
                    interest: "Interest 1",
                    phone: "1234-1234-1234",
                    date: "28/04/2025",
                    status: "Pending",
                  ),
                  const SizedBox(height: 12),
                  _buildLeadCard(
                    context,
                    name: "Maxim",
                    interest: "Interest 2",
                    phone: "1234-1234-1235",
                    date: "25/04/2025",
                    status: "Assigned",
                  ),
                  const SizedBox(height: 12),
                  _buildLeadCard(
                    context,
                    name: "Nurbek",
                    interest: "Interest 2",
                    phone: "1223-3445-5678",
                    date: "03/03/2025",
                    status: "Closed",
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),

        // ✅ Reusable profile panel
        ProfileHostessPanel(controller: _profileController),
      ],
    );
  }

  Widget _buildLeadCard(
    BuildContext context, {
    required String name,
    required String interest,
    required String phone,
    required String date,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case "Pending":
        statusColor = Colors.white70;
        break;
      case "Assigned":
        statusColor = Colors.amberAccent;
        break;
      case "Closed":
        statusColor = Colors.greenAccent;
        break;
      default:
        statusColor = Colors.white70;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeadDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
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
