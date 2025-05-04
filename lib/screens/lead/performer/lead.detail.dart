// Lead Detail Page : made by Leo on 2025.05.03

import 'package:flutter/material.dart';
import 'package:boostseller/screens/lead/performer/detail/assigned.lead.detail.dart';
import 'package:boostseller/screens/lead/performer/detail//presentation.lead.detail.dart';
import 'package:boostseller/screens/lead/performer/detail//testdrive.lead.detail.dart';

class LeadDetailScreen extends StatefulWidget {
  final String status;
  const LeadDetailScreen({super.key, required this.status});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.status == "Assigned") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AssignedLeadDetailScreen()),
        );
      } else if (widget.status == "Presentation") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PresentationLeadDetailScreen(),
          ),
        );
      } else if (widget.status == "Test Drive") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TestDriveLeadDetailScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown status: ${widget.status}")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
    );
  }
}
