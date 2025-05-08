// Lead Detail Page : made by Leo on 2025.05.03

import 'package:flutter/material.dart';
import 'package:boostseller/screens/lead/performer/detail/assigned.lead.detail.dart';
import 'package:boostseller/screens/lead/performer/detail//presentation.lead.detail.dart';
import 'package:boostseller/screens/lead/performer/detail//testdrive.lead.detail.dart';
import 'package:boostseller/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/screens/lead/performer/lead.list.dart';
import 'package:boostseller/model/lead.dart';

class LeadDetailScreen extends StatefulWidget {
  // final String status;
  // final String name;
  // final String interest;
  // final String phone;
  // final String date;
  final Lead lead;

  const LeadDetailScreen({
    super.key,
    // required this.status,
    // required this.name,
    // required this.interest,
    // required this.phone,
    // required this.date,
    required this.lead,
  });

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.lead.status == "Assigned") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AssignedLeadDetailScreen()),
        );
      } else if (widget.lead.status == "Presentation") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PresentationLeadDetailScreen(),
          ),
        );
      } else if (widget.lead.status == "Test Drive") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TestDriveLeadDetailScreen()),
        );
      } else if (widget.lead.status == "Completed") {
        ToastUtil.success("Developing...");
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (widget.lead.status == "Closed") {
        ToastUtil.success("Developing...");
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (widget.lead.status == "Accepted") {
        ToastUtil.success("Developing...");
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown status: ${widget.lead.status}")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Config.backgroundColor,
      body: Center(child: CircularProgressIndicator(color: Colors.blue)),
    );
  }
}
