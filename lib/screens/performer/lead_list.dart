// // Lead List Page : made by Leo on 2025/05/04

import 'package:boostseller/widgets/button_effect.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/lead_card.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/model/lead_model.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'dart:async';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:intl/intl.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';

class PerformerDashboardScreen extends StatefulWidget {
  const PerformerDashboardScreen({super.key});

  @override
  State<PerformerDashboardScreen> createState() =>
      _PerformerDashboardScreenState();
}

class _PerformerDashboardScreenState extends State<PerformerDashboardScreen>
    with WidgetsBindingObserver {
  int selectedTab = 0;
  List<Map<String, dynamic>> assignedLeads = [];
  List<Map<String, dynamic>> acceptedLeads = [];
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();
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
      Map<String, dynamic> newLead = data['lead'];
      setState(() {
        if (data['type'] == 'assigned') {
          final exists = assignedLeads.any(
            (lead) => lead['id'] == newLead['id'],
          );
          if (!exists) {
            assignedLeads.insert(0, newLead);
          }
        } else if (data['type'] == 'escalated') {
          assignedLeads.removeWhere((lead) => lead['id'] == data['lead']['id']);
        }
      });
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
    final performerId = userProvider.user?.performer?.id;
    await Future.delayed(Duration.zero);
    loadingProvider.setLoading(true);
    try {
      await Future.wait([
        isApprovedCheck(),
        connectServer(userProvider.user),
        fetchAssignedLeads(performerId),
        fetchAcceptedLeads(performerId),
        fetchUnreadCount(userProvider.user?.id),
      ]);
    } catch (e) {
      ToastUtil.error(getText("data_load_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> isApprovedCheck() async {
    final api = ApiService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final userId = userProvider.user?.id;
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
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> connectServer(user) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final socketService = SocketService();
    socketService.setUserProvider(userProvider);
    socketService.initContext(context);
    if (user != null && user.id.isNotEmpty) {
      socketService.connect(user.id); // Ensure connect() accepts userId
    }
  }

  Future<void> fetchAssignedLeads(performerId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/performer/lead/assigned', {
        'performerId': performerId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        final List<dynamic> data = jsonData['leads'];
        setState(() {
          assignedLeads = List<Map<String, dynamic>>.from(data);
        });
      } else {
        ToastUtil.error(getText("lead_load_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> fetchAcceptedLeads(performerId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/performer/lead/accepted', {
        'performerId': performerId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        final List<dynamic> data = jsonData['leads'];
        setState(() {
          acceptedLeads = List<Map<String, dynamic>>.from(data);
        });
      } else {
        ToastUtil.error(getText("lead_load_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> fetchUnreadCount(userId) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
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
        ToastUtil.error(getText("notification_load_failed_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
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
    leadSub?.cancel(); // Cancel the stream when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<LoadingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;
    String langCode = context.watch<LanguageProvider>().languageCode;
    final leads = selectedTab == 0 ? assignedLeads : acceptedLeads;
    final leadType = selectedTab == 0 ? 'assigned' : 'accepted';
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
            resizeToAvoidBottomInset: true,
            backgroundColor: Config.backgroundColor,
            // appBar: AppBar(
            //   backgroundColor: Config.appbarColor,
            //   elevation: 0,
            //   leading: Padding(
            //     padding: const EdgeInsets.only(left: 20),
            //     child: GestureDetector(
            //       onTap: () async {
            //         final prefs = await SharedPreferences.getInstance();
            //         final role =
            //             prefs.getString('auth_token')?.toLowerCase() ?? '';
            //         if (role.isNotEmpty) {
            //           await ExitDialog.show();
            //         } else {
            //           NavigationService.pushReplacementNamed('/onboarding');
            //         }
            //       },
            //       child: Container(
            //         width: 35,
            //         height: 35,
            //         decoration: const BoxDecoration(
            //           shape: BoxShape.circle,
            //           color: Config.activeButtonColor,
            //         ),
            //         alignment: Alignment.center,
            //         child: const Icon(
            //           Icons.arrow_back,
            //           size: Config.appBarBackIconSize,
            //           color: Config.iconDefaultColor,
            //         ),
            //       ),
            //     ),
            //   ),

            //   actions: [
            //     // Notification icon with badge
            //     Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 20),
            //       child: GestureDetector(
            //         onTap: () {
            //           NavigationService.pushReplacementNamed('/notifications');
            //         },
            //         child: Stack(
            //           clipBehavior: Clip.none,
            //           children: [
            //             Container(
            //               width: 35,
            //               height: 35,
            //               decoration: const BoxDecoration(
            //                 shape: BoxShape.circle,
            //                 color: Config.activeButtonColor,
            //               ),
            //               alignment: Alignment.center,
            //               child: const Icon(
            //                 Icons.notifications,
            //                 size: 30,
            //                 color: Config.iconDefaultColor,
            //               ),
            //             ),

            //             // Badge
            //             if (unreadCount > 0)
            //               Positioned(
            //                 right: -2,
            //                 top: -2,
            //                 child: Container(
            //                   padding: const EdgeInsets.symmetric(
            //                     horizontal: 5,
            //                     vertical: 2,
            //                   ),
            //                   constraints: const BoxConstraints(
            //                     minWidth: 18,
            //                     minHeight: 18,
            //                   ),
            //                   decoration: BoxDecoration(
            //                     color: Config.notificationBadgeColor,
            //                     borderRadius: BorderRadius.circular(10),
            //                     border: Border.all(
            //                       color: Colors.white,
            //                       width: 1,
            //                     ),
            //                   ),
            //                   child: Text(
            //                     unreadCount > 99
            //                         ? '99+'
            //                         : unreadCount.toString(),
            //                     style: const TextStyle(
            //                       color: Colors.white,
            //                       fontSize: 10,
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                     textAlign: TextAlign.center,
            //                   ),
            //                 ),
            //               ),
            //           ],
            //         ),
            //       ),
            //     ),

            //     // Profile avatar or fallback
            //     Padding(
            //       padding: const EdgeInsets.only(right: 20),
            //       child: GestureDetector(
            //         onTap: () {
            //           _profileController.toggle();
            //         },
            //         child:
            //             avatarPath.isNotEmpty
            //                 ? CircleAvatar(
            //                   radius: 17.5,
            //                   backgroundImage: CachedNetworkImageProvider(
            //                     '$baseUrl$avatarPath',
            //                   ),
            //                   backgroundColor: Colors.transparent,
            //                 )
            //                 : Container(
            //                   width: 35,
            //                   height: 35,
            //                   decoration: const BoxDecoration(
            //                     shape: BoxShape.circle,
            //                     color: Config.activeButtonColor,
            //                   ),
            //                   alignment: Alignment.center,
            //                   child: const Icon(
            //                     Icons.account_circle,
            //                     size: Config.appBarIconSize,
            //                     color: Config.iconDefaultColor,
            //                   ),
            //                 ),
            //       ),
            //     ),
            //   ],
            // ),
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
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
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
                        getText("Work with leads!", langCode),
                        style: TextStyle(
                          fontSize: Config.subTitleFontSize,
                          color: Config.subTitleFontColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tabs
                      Row(
                        children: [
                          _buildTab(
                            "${getText("Assigned", langCode)}(${assignedLeads.length})",
                            selectedTab == 0,
                            () {
                              setState(() => selectedTab = 0);
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildTab(
                            "${getText("Accepted", langCode)}(${acceptedLeads.length})",
                            selectedTab == 1,
                            () {
                              setState(() => selectedTab = 1);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child:
                            leads.isEmpty
                                ? _buildEmptyState(leadType, context)
                                : ListView.builder(
                                  itemCount: leads.length,
                                  itemBuilder: (context, index) {
                                    final lead = leads[index];
                                    return LeadCard(
                                      key: ValueKey(
                                        lead['id'].toString() + langCode,
                                      ),
                                      role: 'performer',
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
                                        additionalInfo:
                                            (lead['additionalInfo']
                                                    as List<dynamic>?)
                                                ?.map(
                                                  (e) =>
                                                      Map<String, dynamic>.from(
                                                        e,
                                                      ),
                                                )
                                                .toList(),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Toggleable Profile Panel
          PerformerProfilePanel(controller: _profileController),
        ],
      ),
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

  Widget _buildEmptyState(String type, BuildContext context) {
    String langCode = context.watch<LanguageProvider>().languageCode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Config.iconDefaultColor,
            ),
            const SizedBox(height: 20),
            Text(
              type == 'assigned'
                  ? getText("No Assigned Leads", langCode)
                  : getText("No Accepted Leads", langCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              type == 'assigned'
                  ? getText("assigned_empty", langCode)
                  : getText("accepted_empty", langCode),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
