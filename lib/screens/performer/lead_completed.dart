// // Lead List Page : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'dart:async';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class LeadCompletedScreen extends StatefulWidget {
  const LeadCompletedScreen({super.key});

  @override
  State<LeadCompletedScreen> createState() => _LeadCompletedScreenState();
}

class _LeadCompletedScreenState extends State<LeadCompletedScreen> {
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();
  final baseUrl = Config.realBackendURL;
  List<Map<String, dynamic>> stages = [];
  String? interestId;
  String _lastLangCode = '';
  bool _hasPreloadedTranslations = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (interestId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      interestId = args['interestId'];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        initializeData(interestId);
      });
    }
  }

  Future<void> initializeData(interestId) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    await Future.delayed(Duration.zero);
    loadingProvider.setLoading(true);
    try {
      await Future.wait([fetchStages(interestId)]);
    } catch (e) {
      ToastUtil.error(getText("data_load_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> fetchStages(interestId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    try {
      final response = await api.post('/api/performer/lead/stage/complete', {
        'interestId': interestId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        for (var stage in jsonData['stages']) {
          final translatedName = await TranslatorHelper.translateText(
            stage['name'],
            langCode,
          );
          stage['translatedName'] = translatedName;
        }
        if (!mounted) return;
        setState(() {
          stages = List<Map<String, dynamic>>.from(jsonData['stages']);
        });
      } else {
        ToastUtil.error(getText("data_load_error_message", langCode));
      }
    } catch (e) {
      debugPrint("Exception: $e");
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> translateStages(String langCode) async {
    _hasPreloadedTranslations = true;
    _lastLangCode = langCode;
    List<Map<String, dynamic>> translatedStages = [];

    for (var stage in stages) {
      final translatedName = await TranslatorHelper.translateText(
        stage['name'],
        langCode,
      );

      translatedStages.add({
        ...stage, // copy original stage
        'translatedName': translatedName, // add new key
      });
    }

    setState(() {
      stages = translatedStages;
    });
  }

  @override
  void dispose() {
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
    if (!_hasPreloadedTranslations || _lastLangCode != langCode) {
      translateStages(langCode);
    }
    return BackOverrideWrapper(
      onBack: () async {
        NavigationService.pushReplacementNamed('/performer-dashboard');
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Config.backgroundColor,
            appBar: CustomAppBar(
              unreadCount: unreadCount,
              avatarPath: avatarPath.isNotEmpty ? '$baseUrl$avatarPath' : '',
              onBackTap: () {
                NavigationService.pushReplacementNamed('/performer-dashboard');
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          // '🎉 Lead Successfully Completed!',
                          getText("Lead Successfully Completed!", langCode),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          getText("complete_title", langCode),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),

                        const SizedBox(height: 30),

                        Column(
                          children: List.generate(stages.length, (index) {
                            final Map<String, dynamic> stage = stages[index];
                            final String stageName =
                                stage['translatedName'] ?? stage['name'];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline indicator
                                Column(
                                  children: [
                                    // Top icon
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.greenAccent,
                                      size: 26,
                                    ),
                                    // Line below the icon except for the last item
                                    if (index != stages.length - 1)
                                      Container(
                                        width: 2,
                                        height: 40,
                                        color: Colors.greenAccent.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Stage name
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      stageName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),

                        const SizedBox(height: 40),

                        // Congratulatory Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Config.activeButtonColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 36,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  getText("complete_done", langCode),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
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
}
