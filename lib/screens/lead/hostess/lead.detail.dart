import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/hostess/profile.panel.dart';

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();
  bool _showMore = false;

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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lead Detail",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Oleh",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        _buildDetailRow("Phone", "1-234-567-890"),
                        _buildDetailRow("Interest", "Interest 1"),
                        _buildDetailRow("Register ID", "1234-1234-1234"),
                        _buildDetailRow("Register Date", "28/04/2025"),

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
                                fontSize: 13,
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
