// Performer profile panel : updated by Leo on 2025/05/15

import 'dart:convert';
import 'package:boostseller/utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/services/api_services.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class ProfilePerformerPanelController extends ChangeNotifier {
  bool _isVisible = false;
  bool get isVisible => _isVisible;

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void close() {
    _isVisible = false;
    notifyListeners();
  }
}

class PerformerProfilePanel extends StatefulWidget {
  final ProfilePerformerPanelController controller;

  const PerformerProfilePanel({super.key, required this.controller});

  @override
  State<PerformerProfilePanel> createState() => _PerformerProfilePanelState();
}

class _PerformerProfilePanelState extends State<PerformerProfilePanel> {
  Map<String, dynamic>? profile;
  bool loading = false;
  final baseUrl = Config.realBackendURL;
  bool disturbFlag = true;
  Map<String, dynamic> performerInfo = {};
  String _lastLangCode = '';
  bool _hasPreloadedTranslations = false;
  final Map<String, String> _translatedUserInfo = {};
  int conversion = 0;
  int responsiveness = 0;
  int effectiveness = 0;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (widget.controller.isVisible) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        setState(() {
          disturbFlag = userProvider.user?.performer?.available ?? true;
        });
        final performerId = userProvider.user?.performer?.id;
        getPerformerInfo(performerId);
      }
    });
  }

  void _preloadTranslatedUserInfo(String langCode, String name) async {
    _hasPreloadedTranslations = true;
    _lastLangCode = langCode;
    _translatedUserInfo.clear();
    final translatedName = await TranslatorHelper.translateText(name, langCode);
    setState(() {
      _translatedUserInfo['name'] = translatedName;
    });
  }

  Future<void> getPerformerInfo(performerId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    if (performerId == null) return;
    final api = ApiService();
    try {
      final response = await api.post('/api/profile/performer', {
        'performerId': performerId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (!mounted) return;
        setState(() {
          performerInfo = jsonData['performer'] ?? {};
          conversion = (jsonData['conversion'] ?? 0).toInt();
          responsiveness = (jsonData['responsiveness'] ?? 0).toInt();
          effectiveness = (jsonData['effectiveness'] ?? 0).toInt();
        });
      } else {
        ToastUtil.error(getText("data_load_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> _uploadImage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => loading = true);

      try {
        final userId = userProvider.user?.id;
        FormData formData = FormData.fromMap({
          "profile_image": await MultipartFile.fromFile(picked.path),
          "userId": userId,
        });
        final api = ApiService();
        final response = await api.uploadFile(
          path: "/api/profile/upload-image",
          formData: formData,
        );
        Map<String, dynamic> jsonData = jsonDecode(response?.data);
        if ((response?.statusCode == 200 || response?.statusCode == 201) &&
            !jsonData['error']) {
          ToastUtil.success(getText("avatar_upload_success", langCode));
          final updatedUser = userProvider.user!.copyWith(
            avatarPath: jsonData['imageUrl'],
          );
          userProvider.setUser(updatedUser);
        } else {
          ToastUtil.error(getText("avatar_upload_failed", langCode));
        }
      } catch (e) {
        debugPrint('Error: $e');
        ToastUtil.error(getText("ajax_error_message", langCode));
      } finally {
        setState(() => loading = false);
      }
    }
  }

  Future<void> setDisturb(disturbFlag) async {
    setState(() => loading = true);
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
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final String name = user?.name ?? '';
    final String translatedName = _translatedUserInfo['name'] ?? name;
    final String phoneNumber = user?.phoneNumber ?? '';
    final int assignedCount = performerInfo['assignedCount'] ?? 0;
    final int acceptedCount = performerInfo['acceptedCount'] ?? 0;
    final int completedCount = performerInfo['completedCount'] ?? 0;
    String langCode = context.watch<LanguageProvider>().languageCode;

    if (!_hasPreloadedTranslations || _lastLangCode != langCode) {
      _preloadTranslatedUserInfo(langCode, name);
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (!widget.controller.isVisible) return const SizedBox.shrink();

        return Stack(
          children: [
            // Tap outside to close
            GestureDetector(
              onTap: widget.controller.toggle,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withAlpha(102),
              ),
            ),

            // Side panel
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.7,
              child: SafeArea(
                child: Material(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    GestureDetector(
                                      onTap: _uploadImage,
                                      child: CircleAvatar(
                                        radius: 70,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            avatarPath.isNotEmpty
                                                ? CachedNetworkImageProvider(
                                                  '$baseUrl$avatarPath',
                                                )
                                                : const AssetImage(
                                                      'assets/profile_performer.png',
                                                    )
                                                    as ImageProvider,
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: GestureDetector(
                                        onTap: _uploadImage,
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.black54,
                                          radius: 16,
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.home,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          translatedName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          phoneNumber,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          getText("performer", langCode),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),

                                // const Divider(color: Colors.white24),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(thickness: 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.emoji_events_rounded,
                                        size: 30,
                                        color: Colors.white,
                                      ), // or use Image.asset / Image.network
                                    ),
                                    const Expanded(
                                      child: Divider(thickness: 1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    getText("Score", langCode),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _scoreRow(
                                  getText("Conversion", langCode),
                                  "$conversion %",
                                ),
                                _scoreRow(
                                  getText("Responsiveness", langCode),
                                  "$responsiveness s",
                                ),
                                _scoreRow(
                                  getText("Effectiveness", langCode),
                                  "$effectiveness %",
                                ),
                                const SizedBox(height: 8),
                                // const Divider(color: Colors.white24),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(thickness: 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.people,
                                        size: 30,
                                        color: Colors.white,
                                      ), // or use Image.asset / Image.network
                                    ),
                                    const Expanded(
                                      child: Divider(thickness: 1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    getText("Leads", langCode),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _scoreRow(
                                  getText("Assigned", langCode),
                                  assignedCount.toString(),
                                ),
                                _scoreRow(
                                  getText("Accepted", langCode),
                                  acceptedCount.toString(),
                                ),
                                _scoreRow(
                                  getText("Completed", langCode),
                                  completedCount.toString(),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(thickness: 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.settings,
                                        size: 30,
                                        color: Colors.white,
                                      ), // or use Image.asset / Image.network
                                    ),
                                    const Expanded(
                                      child: Divider(thickness: 1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    getText("Setting", langCode),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getText("Do Not Disturb", langCode),
                                      style: TextStyle(
                                        color: Config.titleFontColor,
                                        fontSize: Config.subTitleFontSize,
                                      ),
                                    ),
                                    Switch(
                                      value: !disturbFlag,
                                      onChanged: (val) {
                                        setState(() {
                                          disturbFlag = !val;
                                        });
                                        setDisturb(val);
                                      },
                                      activeColor: Config.activeButtonColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              widget.controller.close();
                              userProvider.logout();
                              final socketService = SocketService();
                              socketService.disconnect();
                              NavigationService.pushReplacementNamed(
                                '/onboarding',
                              );
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: Text(
                              getText("Logout", langCode),
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Config.activeButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (loading) const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }

  Widget _scoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label :",
              style: const TextStyle(color: Colors.white60),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
