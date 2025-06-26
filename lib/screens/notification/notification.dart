import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/model/notification_model.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';
import 'package:boostseller/screens/profile/hostess/profile_panel.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ProfilePerformerPanelController _profilePerformerController =
      ProfilePerformerPanelController();
  final ProfileHostessPanelController _profileHostessController =
      ProfileHostessPanelController();
  final baseUrl = Config.realBackendURL;
  List<NotificationModel> translatedNotifications = [];
  List<NotificationModel> rawNotifications = [];
  StreamSubscription? notificationSub;
  String lastLangCode = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData();
    });

    // Do NOT access Provider directly in initState — wrap in addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLang =
          Provider.of<LanguageProvider>(context, listen: false).languageCode;

      notificationSub = SocketService().leadNotifications.listen((data) async {
        NotificationModel newNotification = NotificationModel.fromJson(
          data['notification'],
        );

        NotificationModel translatedNotification = await translateNotification(
          newNotification,
          currentLang,
        );

        setState(() {
          translatedNotifications.insert(0, translatedNotification);
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLang = Provider.of<LanguageProvider>(context).languageCode;

    if (lastLangCode != currentLang) {
      lastLangCode = currentLang;
      translateNotifications(currentLang);
    }
  }

  @override
  void dispose() {
    notificationSub?.cancel(); // Cancel the stream when widget is disposed
    super.dispose();
  }

  // List<Map<String, dynamic>> notifications = [];
  String formatTimeAgo(DateTime timestamp) {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ${getText("ago", langCode)}';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ${getText("ago", langCode)}';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ${getText("ago", langCode)}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ${getText("ago", langCode)}';
    }
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ${getText("ago", langCode)}';
    }
    if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}mo ${getText("ago", langCode)}';
    }

    return '${(diff.inDays / 365).floor()}y ${getText("ago", langCode)}';
  }

  Future<void> initializeData() async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    loadingProvider.setLoading(true);
    try {
      await Future.wait([fetchNotifications(userProvider.user?.id)]);
    } catch (e) {
      ToastUtil.error(getText("data_load_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> translateNotifications(String langCode) async {
    final List<NotificationModel> translatedList = await Future.wait(
      rawNotifications.map((notification) async {
        final translatedTitle = await TranslatorHelper.translateText(
          notification.title,
          langCode,
        );
        final translatedMessage = await TranslatorHelper.translateText(
          notification.message,
          langCode,
        );

        return notification.copyWith(
          title: translatedTitle,
          message: translatedMessage,
        );
      }),
    );

    setState(() {
      translatedNotifications = translatedList;
      lastLangCode = langCode;
    });
  }

  Future<NotificationModel> translateNotification(
    NotificationModel notification,
    String langCode,
  ) async {
    final translatedTitle = await TranslatorHelper.translateText(
      notification.title,
      langCode,
    );

    final translatedMessage = await TranslatorHelper.translateText(
      notification.message,
      langCode,
    );

    return notification.copyWith(
      title: translatedTitle,
      message: translatedMessage,
    );
  }

  Future<void> fetchNotifications(userId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/notification', {
        'receiveId': userId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        setState(() {
          rawNotifications =
              (jsonData['notifications'] as List)
                  .map((item) => NotificationModel.fromJson(item))
                  .toList();
        });
        await translateNotifications(langCode);
      } else {
        ToastUtil.error(getText("notification_load_failed_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("notification_load_failed_message", langCode));
    }
  }

  Future<void> markAsRead(int index, id) async {
    setState(() {
      translatedNotifications[index].isRead = true;
    });
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notificationProvider.decrement();
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/notification/read', {'id': id});
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
      } else {
        ToastUtil.error(getText("submit_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<LoadingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;

    return BackOverrideWrapper(
      onBack: () {
        if (user?.role == 'performer') {
          NavigationService.pushReplacementNamed('/performer-dashboard');
        } else if (user?.role == 'hostess') {
          NavigationService.pushReplacementNamed('/hostess-dashboard');
        }
      },
      child: LoadingOverlay(
        isLoading: loadingProvider.isLoading,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Config.backgroundColor,
              appBar: CustomAppBar(
                unreadCount: unreadCount,
                avatarPath: avatarPath.isNotEmpty ? '$baseUrl$avatarPath' : '',
                onBackTap: () {
                  if (user?.role == 'performer') {
                    NavigationService.pushReplacementNamed(
                      '/performer-dashboard',
                    );
                  } else if (user?.role == 'hostess') {
                    NavigationService.pushReplacementNamed(
                      '/hostess-dashboard',
                    );
                  }
                },
                onProfileTap: () {
                  if (user?.role == 'hostess') {
                    _profileHostessController.toggle();
                  } else if (user?.role == 'performer') {
                    _profilePerformerController.toggle();
                  }
                },
                onNotificationTap: () {},
              ),
              body:
                  translatedNotifications.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: translatedNotifications.length,
                        itemBuilder: (context, index) {
                          final item = translatedNotifications[index];
                          return GestureDetector(
                            onTap: () => markAsRead(index, item.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color:
                                    item.isRead
                                        ? Config.leadCardColor
                                        : Config.containerColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  item.isRead
                                      ? Icons.notifications_none
                                      : Icons.notifications_active,
                                  color:
                                      item.isRead
                                          ? Colors.grey
                                          : Colors.amberAccent,
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Config.titleFontColor,
                                    fontWeight:
                                        item.isRead
                                            ? FontWeight.w400
                                            : FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  item.message,
                                  style: TextStyle(
                                    color: Config.subTitleFontColor,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Text(
                                  formatTimeAgo(item.createdAt),
                                  style: const TextStyle(
                                    color: Config.activeButtonColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            PerformerProfilePanel(controller: _profilePerformerController),
            ProfileHostessPanel(controller: _profileHostessController),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String langCode = context.watch<LanguageProvider>().languageCode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 80,
              color: Config.iconDefaultColor,
            ),
            const SizedBox(height: 20),
            Text(
              getText("No Notifications", langCode),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              getText("empty_notification_message", langCode),
              style: TextStyle(
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
