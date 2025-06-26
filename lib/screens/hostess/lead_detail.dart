// Lead Detail Page : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/hostess/profile_panel.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/model/lead_model.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'package:boostseller/services/api_services.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'dart:convert';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class HostessLeadDetailScreen extends StatefulWidget {
  const HostessLeadDetailScreen({super.key});

  @override
  State<HostessLeadDetailScreen> createState() =>
      _HostessLeadDetailScreenState();
}

class _HostessLeadDetailScreenState extends State<HostessLeadDetailScreen> {
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();
  bool _showMore = false;
  final baseUrl = Config.realBackendURL;
  final socketService = SocketService();
  String? _translatedName;
  String? _translatedStatus;
  String? _translatedInterest;
  List<Map<String, String>>? _translatedAdditionalInfo;
  String? lastTranslatedLangCode;

  Future<void> closedLead(lead) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    loadingProvider.setLoading(true);
    try {
      final response = await api.post('/api/hostess/lead/close', {
        'registerId': lead.registerId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(getText("Lead Successfully Closed!", langCode));
        NavigationService.pushReplacementNamed('/hostess-dashboard');
      } else {
        ToastUtil.error(getText("closed_lead_failed_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("closed_lead_failed_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> nextRound(lead) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    loadingProvider.setLoading(true);
    try {
      socketService.assignLead(lead);
      await Future.delayed(const Duration(seconds: 2));
      NavigationService.pushReplacementNamed('/hostess-dashboard');
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      loadingProvider.setLoading(false);
    }
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

  @override
  Widget build(BuildContext context) {
    //final width = MediaQuery.of(context).size.width;
    final loadingProvider = Provider.of<LoadingProvider>(context);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final LeadModel lead = args['lead'] as LeadModel;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;
    String langCode = context.watch<LanguageProvider>().languageCode;
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
          body: LoadingOverlay(
            isLoading: loadingProvider.isLoading,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      getText("Lead Detail", langCode),
                      style: TextStyle(
                        fontSize: Config.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Config.titleFontColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Config.leadDetailBackroudColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                      color: _getStatusColor(lead.status),
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

                          const Divider(
                            color: Config.leadDivederColor,
                            height: 20,
                          ),
                          _buildDetailRow(
                            getText("Phone Number", langCode),
                            lead.phone,
                          ),
                          _buildDetailRow(
                            getText("Interest", langCode),
                            _translatedInterest ?? lead.interest,
                          ),
                          // _buildDetailRow(getText("ID", langCode), lead.idStr),
                          _buildDetailRow(
                            getText("Register Date", langCode),
                            lead.date,
                          ),

                          if (_showMore) ...[
                            ...?_translatedAdditionalInfo?.map((item) {
                              return _buildDetailRow(
                                item['label'] ?? '',
                                item['value'] ?? '',
                              );
                            }),
                          ],
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() => _showMore = !_showMore);
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _showMore
                                    ? getText("less ...", langCode)
                                    : getText("more...", langCode),
                                style: const TextStyle(
                                  fontSize: Config.leadTextFontSize,
                                  color: Colors.white60,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (lead.status.toLowerCase() == 'pendding')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _actionButton(
                            getText("Next", langCode),
                            Config.activeButtonColor,
                            Colors.white,
                            () {
                              nextRound(lead.toJson());
                            },
                          ),
                          _actionButton(
                            getText("Close", langCode),
                            Config.deactiveButtonColor,
                            Colors.white,
                            () => closedLead(lead),
                          ),
                        ],
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

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'assigned':
      return Colors.blue;
    case 'closed':
      return Colors.red;
    case 'completed':
      return Colors.green;
    case 'pendding':
      return Colors.orangeAccent;
    default:
      return Colors.indigo;
  }
}
