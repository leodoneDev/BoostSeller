// Lead List Page : made by Leo on 2025/05/04

import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/hostess/profile_panel.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/widgets/lead_card.dart';
import 'package:boostseller/model/lead_model.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:intl/intl.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'dart:async';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';

class HostessDashboardScreen extends StatefulWidget {
  const HostessDashboardScreen({super.key});

  @override
  State<HostessDashboardScreen> createState() => _HostessDashboardScreenState();
}

class _HostessDashboardScreenState extends State<HostessDashboardScreen>
    with WidgetsBindingObserver {
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();

  List<Map<String, dynamic>> leads = [];
  List<Map<String, dynamic>> interests = [];
  List<Map<String, dynamic>> fields = [];
  final baseUrl = Config.realBackendURL;
  StreamSubscription? leadSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData();
    });

    leadSub = SocketService().leadNotifications.listen((data) {
      if (data['type'] == 'pendding') {
        Map<String, dynamic> newLead = data['lead'];
        if (!mounted) return;
        setState(() {
          // Remove existing lead with same registerId
          leads.removeWhere(
            (lead) => lead['registerId'] == newLead['registerId'],
          );

          // Insert new lead at the beginning of the list
          leads.insert(0, newLead);
        });
      }
    });
  }

  String formatDate(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  String formatStatus(String status) {
    if (status.isEmpty) return status;
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  Future<void> initializeData() async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final userId = userProvider.user?.id;
    final adminId = userProvider.user?.adminId;
    print(adminId);
    await Future.delayed(Duration.zero);
    loadingProvider.setLoading(true);
    try {
      await Future.wait([
        isApprovedCheck(userId),
        connectServer(),
        fetchInterestList(adminId),
        fetchLeadAdditionInfoList(adminId),
        loadLeads(userId),
        fetchUnreadCount(userId),
      ]);
    } catch (e) {
      ToastUtil.error(getText("data_load_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> isApprovedCheck(userId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final response = await api.post('/api/auth/user', {'userId': userId});
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (!jsonData['isApproved']) {
          userProvider.logout();
          NavigationService.pushReplacementNamed('/pendding-approval');
        }
      } else {
        userProvider.logout();
        NavigationService.pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("data_load_error_message", langCode));
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

  Future<void> fetchInterestList(adminId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/interest', {'adminId': adminId});
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        interests = List<Map<String, dynamic>>.from(jsonData['interests']);
      } else {
        if (jsonData['empty']) {
          ToastUtil.error(getText("not_found_interest_message", langCode));
        }
        ToastUtil.error(getText("interest_load_failed_message", langCode));
      }
    } catch (e) {
      debugPrint("Exception: $e");
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> fetchLeadAdditionInfoList(adminId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/hostess/lead/field', {
        'adminId': adminId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        fields = List<Map<String, dynamic>>.from(jsonData['fields']);
      } else {
        if (jsonData['empty']) {
          ToastUtil.error(getText("not_found_lead_additional_data", langCode));
        }
        ToastUtil.error(getText("lead_additional_data_failed", langCode));
      }
    } catch (e) {
      debugPrint("Exception: $e");
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> loadLeads(String? userId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/hostess/lead', {'userId': userId});
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        final List<dynamic> data = jsonData['leads'];
        leads = List<Map<String, dynamic>>.from(data);
      } else {
        ToastUtil.error(getText("lead_load_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("data_load_error_message", langCode));
    }
  }

  Future<void> fetchUnreadCount(userId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final api = ApiService();
    try {
      final response = await api.post('/api/notification/unread', {
        'receiveId': userId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        notificationProvider.setUnreadCount(jsonData['unReadCount']);
      } else {
        ToastUtil.error(getText("data_load_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("data_load_error_message", langCode));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-fetch or refresh data when app is resumed
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (userId != null) {
        initializeData(); // or just call loadLeads(userId);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    leadSub?.cancel(); // Cancel the subscription when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final loadingProvider = Provider.of<LoadingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;
    String langCode = context.watch<LanguageProvider>().languageCode;
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
            appBar: CustomAppBar(
              unreadCount: unreadCount,
              avatarPath: avatarPath.isNotEmpty ? '$baseUrl$avatarPath' : '',
              onBackTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final role = prefs.getString('auth_token')?.toLowerCase() ?? '';
                if (role.isNotEmpty) {
                  await ExitDialog.show();
                } else {
                  NavigationService.pushReplacementNamed('/onboarding');
                }
              },
              onProfileTap: () {
                _profileController.toggle();
              },
              onNotificationTap: () {
                NavigationService.pushReplacementNamed('/notifications');
              },
            ),
            body: LoadingOverlay(
              isLoading: loadingProvider.isLoading,
              // loadingText: "Loading data...",
              child: SafeArea(
                child: SingleChildScrollView(
                  // padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        getText("Leads", langCode),
                        style: TextStyle(
                          fontSize: Config.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Config.titleFontColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getText("lead_list_title", langCode),
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
                            NavigationService.pushNamed(
                              '/add-lead',
                              arguments: {
                                'interests': interests,
                                'fields': fields,
                              },
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
                            child: Text(
                              getText("Add", langCode),
                              style: TextStyle(
                                fontSize: Config.buttonTextFontSize,
                                color: Config.buttonTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      leads.isEmpty
                          ? _buildEmptyLeads(context)
                          : Column(
                            children:
                                leads
                                    .map(
                                      (lead) => LeadCard(
                                        key: ValueKey(
                                          lead['id'].toString() + langCode,
                                        ),
                                        role: 'hostess',
                                        langCode: langCode,
                                        lead: LeadModel(
                                          id: lead['id'].toString(),
                                          interestId:
                                              lead['interestId'].toString(),
                                          stageId: lead['stageId'].toString(),
                                          name: lead['name']!,
                                          interest: lead['interest']['name']!,
                                          // idStr: lead['idStr'].toString(),
                                          phone: lead['phoneNumber']!,
                                          date: formatDate(lead['createdAt']!),
                                          status: formatStatus(lead['status']!),
                                          registerId: lead['registerId']!,
                                          isReturn: lead['isReturn'],
                                          // additionalInfo:
                                          //     lead['additionalInfo'],
                                          additionalInfo:
                                              (lead['additionalInfo']
                                                      as List<dynamic>?)
                                                  ?.map(
                                                    (e) => Map<
                                                      String,
                                                      dynamic
                                                    >.from(e),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                    )
                                    .toList(),
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

Widget _buildEmptyLeads(BuildContext context) {
  String langCode = context.watch<LanguageProvider>().languageCode;
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 80, color: Config.iconDefaultColor),
          const SizedBox(height: 20),
          Text(
            getText("No leads found.", langCode),
            style: TextStyle(
              fontSize: Config.titleFontSize,
              fontWeight: FontWeight.bold,
              color: Config.titleFontColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            getText("You haven’t added any leads yet.", langCode),
            style: TextStyle(
              fontSize: Config.subTitleFontSize,
              color: Config.subTitleFontColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
