// Assigned Lead Detail Page : made by Leo on 2025/05/03

import 'package:boostseller/providers/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/model/lead_model.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/utils/toast.dart';
import 'dart:ui';
import 'package:boostseller/services/websocket_service.dart';
import 'dart:async';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignedLeadDetailScreen extends StatefulWidget {
  const AssignedLeadDetailScreen({super.key});

  @override
  State<AssignedLeadDetailScreen> createState() =>
      _AssignedLeadDetailScreenState();
}

class _AssignedLeadDetailScreenState extends State<AssignedLeadDetailScreen> {
  bool _showMore = false;
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();
  final baseUrl = Config.realBackendURL;
  bool doNotDisturb = true;
  List<Map<String, dynamic>> fields = [];
  final socketService = SocketService();
  String? _translatedName;
  String? _translatedStatus;
  String? _translatedInterest;
  List<Map<String, String>>? _translatedAdditionalInfo;
  String? lastTranslatedLangCode;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    doNotDisturb = userProvider.user?.performer?.available ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final langCode = Provider.of<LanguageProvider>(context).languageCode;

    if (lastTranslatedLangCode != langCode) {
      lastTranslatedLangCode = langCode;
      translateLeadDetails(langCode);
    }
  }

  Future<void> translateLeadDetails(String langCode) async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final LeadModel lead = args['lead'] as LeadModel;

    final translatedName = await TranslatorHelper.translateText(
      lead.name,
      langCode,
    );
    final translatedStatus = await TranslatorHelper.translateText(
      lead.status,
      langCode,
    );
    final translatedInterest = await TranslatorHelper.translateText(
      lead.interest,
      langCode,
    );

    List<Map<String, String>> translatedAdditionalInfo = [];

    if (lead.additionalInfo != null) {
      for (final item in lead.additionalInfo!) {
        final translatedLabel = await TranslatorHelper.translateText(
          item['label'],
          langCode,
        );
        final translatedValue = await TranslatorHelper.translateText(
          item['value'].toString(),
          langCode,
        );
        translatedAdditionalInfo.add({
          'label': translatedLabel,
          'value': translatedValue,
        });
      }
    }

    setState(() {
      _translatedName = translatedName;
      _translatedStatus = translatedStatus;
      _translatedInterest = translatedInterest;
      _translatedAdditionalInfo = translatedAdditionalInfo;
    });
  }

  Future<void> setDisturb(disturbFlag) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final performerId = userProvider.user?.performer?.id;
    try {
      final api = ApiService();
      final response = await api.post('/api/setting/disturb', {
        'performerId': performerId,
        'flag': disturbFlag,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (disturbFlag) {
          ToastUtil.success(getText("disturb_on_message", langCode));
        } else {
          ToastUtil.success(getText("disturb_off_message", langCode));
        }
        final currentPerformer = userProvider.user?.performer;
        if (currentPerformer != null) {
          final updatedPerformer = currentPerformer.copyWith(
            available: !disturbFlag,
          );
          userProvider.updatePerformer(updatedPerformer);
        }
      } else {
        ToastUtil.error(getText("submit_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> showDoNotDisturbDialog(BuildContext context, lead) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    bool isDND = userProvider.user?.performer?.available ?? true;
    await showDialog(
      context: context,
      barrierDismissible:
          false, // Set false here because we'll handle dismiss manually
      barrierColor: Colors.transparent, // we manage background color ourselves
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            // Make the blurred background tappable to close dialog
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // Center your dialog normally
            Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    backgroundColor: Config.leadCardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    title: Text(
                      getText("Focus Mode", langCode),
                      style: TextStyle(
                        fontSize: Config.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Config.titleFontColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 10),

                        Text(
                          isDND
                              ? getText("disturb_active", langCode)
                              : getText("disturb_deactive", langCode),
                          style: TextStyle(
                            fontSize: Config.subTitleFontSize,
                            color: Config.subTitleFontColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getText("Do Not Disturb", langCode),
                              style: TextStyle(
                                color: Config.titleFontColor,
                                fontSize: Config.subTitleFontSize,
                              ),
                            ),
                            Switch(
                              value: !isDND,
                              onChanged: (val) {
                                setState(() {
                                  isDND = !val;
                                });
                                setDisturb(val);
                              },
                              activeColor: Config.activeButtonColor,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: EffectButton(
                            onTap: () {
                              acceptLead(lead); // Call API
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Config.activeButtonColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  getText("Confirm & Accept", langCode),
                                  style: TextStyle(
                                    fontSize: Config.buttonTextFontSize,
                                    color: Config.buttonTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> acceptLead(lead) async {
    int acceptedCount = 0;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    final performerId = userProvider.user?.performer?.id;
    final adminId = userProvider.user?.adminId;
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    loadingProvider.setLoading(true);
    try {
      final response = await api.post('/api/performer/lead/accept', {
        'registerId': lead.registerId,
        'performerId': performerId,
        'interestId': lead.interestId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        acceptedCount++;
        ToastUtil.success(getText("Lead accepted successfully", langCode));
        if (jsonData['educationMode']) {
          socketService.educationMode({
            'leadId': lead.id,
            'performerId': performerId,
            'adminId': adminId,
          });
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('acceptedCount', acceptedCount);
        lead.status = jsonData['stageName'];
        lead.stageId = jsonData['stageId'].toString();
        NavigationService.pushReplacementNamed(
          '/sales-stage',
          arguments: {'lead': lead},
        );
      } else {
        if (!jsonData['exist']) {
          ToastUtil.error(getText("not_found_stages", langCode));
          NavigationService.pushReplacementNamed('/performer-dashboard');
        }
        ToastUtil.error(getText("submit_error message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> skipLead(leadId, userId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final performerId = userProvider.user?.performer?.id;

    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    loadingProvider.setLoading(true);
    try {
      socketService.skipLead({
        'leadId': leadId,
        'userId': userId,
        'performerId': performerId,
      });
      await Future.delayed(const Duration(seconds: 2));
      NavigationService.pushReplacementNamed('/performer-dashboard');
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final LeadModel lead = args['lead'] as LeadModel;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;
    String langCode = context.watch<LanguageProvider>().languageCode;
    final acceptedCount = user?.performer?.acceptedCount ?? 0;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: CustomAppBar(
            unreadCount: unreadCount,
            avatarPath: avatarPath.isNotEmpty ? '$baseUrl$avatarPath' : '',
            onBackTap: () {
              Navigator.pop(context);
            },
            onProfileTap: () {
              _profileController.toggle();
            },
            onNotificationTap: () {
              NavigationService.pushReplacementNamed('/notifications');
            },
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getText("Lead assigned to you", langCode),
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getText("Let’s start your work with lead!", langCode),
                    style: TextStyle(
                      fontSize: Config.subTitleFontSize,
                      color: Config.subTitleFontColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Config.leadDetailBackroudColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _translatedName ?? lead.name,
                                style: TextStyle(
                                  fontSize: Config.leadNameFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Config.leadNameColor,
                                ),
                              ),
                              Row(
                                children: [
                                  if (lead.isReturn) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        getText("Return", langCode),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ), // Just 2px between badges
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _translatedStatus ?? lead.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Config.leadDivederColor,
                          height: 1,
                        ),
                        _infoRow(getText("Phone Number", langCode), lead.phone),
                        _infoRow(
                          getText("Interest", langCode),
                          _translatedInterest ?? lead.interest,
                        ),
                        // _infoRow(getText("ID", langCode), lead.idStr),
                        _infoRow(getText("Register Date", langCode), lead.date),
                        if (_showMore) ...[
                          ...?_translatedAdditionalInfo?.map((item) {
                            return _infoRow(
                              item['label'] ?? '',
                              item['value'] ?? '',
                            );
                          }),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(right: 16, top: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _showMore = !_showMore),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _showMore
                                    ? getText('less...', langCode)
                                    : getText('more...', langCode),
                                style: const TextStyle(
                                  fontSize: Config.leadTextFontSize,
                                  color: Config.leadTextFontSizeColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        getText("Accept", langCode),
                        Config.activeButtonColor,
                        Colors.white,
                        () async {
                          final prefs = await SharedPreferences.getInstance();
                          final acceptedCount =
                              prefs.getInt("acceptedCount") ?? 0;
                          if (acceptedCount > 0) {
                            acceptLead(lead);
                          } else {
                            showDoNotDisturbDialog(context, lead);
                          }
                        },
                      ),
                      _actionButton(
                        getText("Skip", langCode),
                        Config.deactiveButtonColor,
                        Colors.white,
                        () => skipLead(lead.registerId, user?.id),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),

        // Performer profile side panel
        PerformerProfilePanel(controller: _profileController),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: RichText(
        text: TextSpan(
          text: "$label : ",
          style: const TextStyle(
            color: Config.leadDetailInfoLabelColor,
            fontSize: Config.leadTextFontSize,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Config.leadDetailInfoColor,
                fontSize: Config.leadTextFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 140,
      height: 50,
      child: EffectButton(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: Config.buttonTextFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
