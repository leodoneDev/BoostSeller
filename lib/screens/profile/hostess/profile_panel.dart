// Hostess profile panel : updated by Leo on 2025/05/15

import 'dart:convert';
import 'package:boostseller/utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/services/api_services.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class ProfileHostessPanelController extends ChangeNotifier {
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

class ProfileHostessPanel extends StatefulWidget {
  final ProfileHostessPanelController controller;

  const ProfileHostessPanel({super.key, required this.controller});

  @override
  State<ProfileHostessPanel> createState() => _ProfileHostessPanelState();
}

class _ProfileHostessPanelState extends State<ProfileHostessPanel> {
  bool loading = false;
  final baseUrl = Config.realBackendURL;
  Map<String, dynamic> hostessInfo = {};
  String _lastLangCode = '';
  bool _hasPreloadedTranslations = false;
  final Map<String, String> _translatedUserInfo = {};

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    widget.controller.addListener(() {
      if (widget.controller.isVisible) {
        final hostessId = userProvider.user?.hostess?.id;
        getHostessInfo(hostessId);
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

  Future<void> getHostessInfo(hostessId) async {
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    if (hostessId == null) return;
    final api = ApiService();
    try {
      final response = await api.post('/api/profile/hostess', {
        'hostessId': hostessId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (!mounted) return;
        setState(() {
          hostessInfo = jsonData['hostess'] ?? {};
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String langCode = context.watch<LanguageProvider>().languageCode;
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final String name = user?.name ?? '';
    final String phoneNumber = user?.phoneNumber ?? '';
    final String translatedName = _translatedUserInfo['name'] ?? name;
    final int totalCount = hostessInfo['totalCount'] ?? 0;
    final int acceptedCount = hostessInfo['acceptedCount'] ?? 0;
    final int completedCount = hostessInfo['completedCount'] ?? 0;

    if (!_hasPreloadedTranslations || _lastLangCode != langCode) {
      _preloadTranslatedUserInfo(langCode, name);
    }
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (!widget.controller.isVisible) return const SizedBox.shrink();
        return Stack(
          children: [
            GestureDetector(
              onTap: widget.controller.toggle,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withAlpha(102),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Material(
                color: const Color(0xFF2C2C2C),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                                    'assets/profile_hostess.png',
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
                              const SizedBox(height: 30),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(Icons.home, translatedName),
                                  const SizedBox(height: 10),
                                  _infoRow(Icons.phone, phoneNumber),
                                  const SizedBox(height: 10),
                                  _infoRow(
                                    Icons.check,
                                    getText("hostess", langCode),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                              Row(
                                children: [
                                  const Expanded(child: Divider(thickness: 1)),
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
                                  const Expanded(child: Divider(thickness: 1)),
                                ],
                              ),
                              const SizedBox(height: 10),
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
                              const SizedBox(height: 10),
                              _stat(getText("Total", langCode), totalCount),
                              _stat(
                                getText("Accepted", langCode),
                                acceptedCount,
                              ),
                              _stat(
                                getText("Completed", langCode),
                                completedCount,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Config.activeButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: Text(
                            getText("Logout", langCode),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            widget.controller.close();
                            userProvider.logout();
                            final socketService = SocketService();
                            socketService.disconnect();
                            NavigationService.pushReplacementNamed(
                              '/onboarding',
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (loading) const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }

  static Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _stat(String label, int value) {
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
          Text("$value", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
