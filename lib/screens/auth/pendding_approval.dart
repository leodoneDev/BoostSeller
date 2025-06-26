import 'package:flutter/material.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';

class ApproveScreen extends StatefulWidget {
  const ApproveScreen({super.key});

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData();
    });
  }

  Future<void> initializeData() async {
    await Future.delayed(Duration.zero);
    try {
      await Future.wait([connectServer(), isApprovedCheck()]);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> connectServer() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final socketService = SocketService();
    socketService.setUserProvider(userProvider);
    socketService.initContext(context);
    if (user != null && user.id.isNotEmpty) {
      socketService.connect(user.id); // Ensure connect() accepts userId
    }
  }

  Future<void> isApprovedCheck() async {
    final api = ApiService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    try {
      final response = await api.post('/api/auth/user', {'userId': userId});
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (jsonData['isApproved']) {
          userProvider.logout();
          NavigationService.pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("data_load_error_message", langCode));
    }
  }

  @override
  void dispose() {
    final socketService = SocketService();
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    String langCode = context.watch<LanguageProvider>().languageCode;

    return BackOverrideWrapper(
      onBack: () async {
        await ExitDialog.show();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  color: Colors.amber,
                  size: 100,
                ),
                const SizedBox(height: 30),
                Text(
                  getText("Awaiting Approval", langCode),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  getText("pendding_title", langCode),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
