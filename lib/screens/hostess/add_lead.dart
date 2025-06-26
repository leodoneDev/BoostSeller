// Add Lead Page : made by Leo on 2025/05/03

import 'package:boostseller/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/hostess/profile_panel.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/widgets/custom_input_text.dart';
import 'package:boostseller/widgets/custom_phone_field.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/widgets/custom_dropdown.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/widgets/dynamic_field.dart';
import 'dart:convert';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/services/api_services.dart';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();

  final TextEditingController nameController = TextEditingController();
  // final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final Map<String, TextEditingController> fieldControllers = {};
  final Map<String, FocusNode> fieldFocusNodes = {};
  List<Map<String, dynamic>> additionalInfos = [];
  final _scrollController = ScrollController();

  String? selectedInterestId;
  String phoneNumber = '';
  final baseUrl = Config.realBackendURL;
  final socketService = SocketService();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final Map<String, String> _translatedLabelsCache = {};
  List<Map<String, dynamic>> translatedInterests = [];
  String _lastLangCode = '';
  bool _hasPreloadedTranslations = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _preloadTranslatedLabelsAndItems(
    List<Map<String, dynamic>> fields,
    String langCode,
  ) async {
    _hasPreloadedTranslations = true;
    _lastLangCode = langCode;
    _translatedLabelsCache.clear();

    for (var field in fields) {
      final label = field['label'] as String;
      final translatedLabel = await TranslatorHelper.translateText(
        label,
        langCode,
      );
      _translatedLabelsCache[label] = translatedLabel;

      // Translate items if they exist
      if (field.containsKey('items') && field['items'] is List) {
        final translatedItems = await Future.wait(
          field['items'].map<Future<String>>((item) async {
            return await TranslatorHelper.translateText(item, langCode);
          }),
        );
        // Cache translated items into field itself
        field['translatedItems'] = translatedItems;
      }
    }

    setState(() {}); // Refresh the UI
  }

  Future<void> _translateInterests(
    List<Map<String, dynamic>> rawInterests,
    String langCode,
  ) async {
    _hasPreloadedTranslations = true;
    _lastLangCode = langCode;
    final translated = await Future.wait(
      rawInterests.map((item) async {
        final translatedName = await TranslatorHelper.translateText(
          item['name'],
          langCode,
        );
        return {...item, 'name': translatedName};
      }),
    );
    setState(() {
      translatedInterests = translated;
    });
  }

  void resetForm() {
    nameController.clear();
    phoneController.clear();
    //idController.clear();
    setState(() {
      phoneNumber = '';
      _autoValidateMode = AutovalidateMode.disabled;
      selectedInterestId = null;
    });
    fieldControllers.forEach((key, controller) {
      controller.clear();
    });
  }

  Future<void> handleAddLead(
    BuildContext context,
    List<Map<String, dynamic>> fields,
  ) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final name = nameController.text.trim();
    // final idStr = idController.text.trim();
    List<Map<String, dynamic>> additionalInfo =
        fields.map((field) {
          final label = field['label'];
          final controller = fieldControllers[label];
          final value = controller?.text.trim() ?? '';

          return {...field, 'value': value};
        }).toList();

    loadingProvider.setLoading(true);
    try {
      final api = ApiService();
      final response = await api.post('/api/hostess/lead/add', {
        // 'idStr': idStr,
        'name': name,
        'phoneNumber': phoneNumber,
        'interestId': selectedInterestId,
        'hostessId': userProvider.user?.hostess?.id,
        'additionalInfo': additionalInfo,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(getText("lead_add_success_message", langCode));
        socketService.assignLead(jsonData['lead']);
        NavigationService.pushReplacementNamed('/hostess-dashboard');
      } else {
        if (jsonData['exist']) {
          ToastUtil.error(getText("lead_exist_message", langCode));
        } else {
          ToastUtil.error(getText("ajax_error_message", langCode));
        }
        resetForm();
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    //idController.dispose();
    _scrollController.dispose();
    fieldControllers.forEach((key, controller) {
      controller.dispose();
    });
    fieldFocusNodes.forEach((key, node) {
      node.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    List<Map<String, dynamic>> interests = args['interests'];
    List<Map<String, dynamic>> fields = args['fields'];
    final loadingProvider = Provider.of<LoadingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;
    String langCode = context.watch<LanguageProvider>().languageCode;
    if (!_hasPreloadedTranslations || _lastLangCode != langCode) {
      _preloadTranslatedLabelsAndItems(fields, langCode);
      _translateInterests(interests, langCode);
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: LoadingOverlay(
        isLoading: loadingProvider.isLoading,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: true,
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
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autoValidateMode,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                getText("New Lead", langCode),
                                style: TextStyle(
                                  fontSize: Config.titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Config.titleFontColor,
                                ),
                              ),
                              const SizedBox(height: 20),

                              CustomLabel(
                                label: getText("Name", langCode),
                                required: true,
                              ),
                              const SizedBox(height: 6),
                              CustomTextField(
                                controller: nameController,
                                autovalidateMode: _autoValidateMode,
                                hint: getText("Name", langCode),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return getText(
                                      "Name is required",
                                      langCode,
                                    );
                                  }
                                  return null;
                                },
                              ),

                              CustomLabel(
                                label: getText("Phone Number", langCode),
                                required: true,
                              ),
                              const SizedBox(height: 6),
                              CustomPhoneField(
                                controller: phoneController,
                                autovalidateMode: _autoValidateMode,
                                onChanged: (phoneNumber) async {
                                  setState(() {
                                    this.phoneNumber = phoneNumber;
                                  });
                                },
                              ),
                              CustomLabel(
                                label: getText("Interest", langCode),
                                required: true,
                              ),
                              const SizedBox(height: 6),
                              CustomDropdown(
                                hint: getText("Interest", langCode),
                                items: translatedInterests,
                                value: selectedInterestId,
                                autovalidateMode: _autoValidateMode,
                                onChanged: (value) {
                                  setState(() => selectedInterestId = value);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return getText(
                                      "Please select an interest",
                                      langCode,
                                    );
                                  }
                                  return null;
                                },
                              ),

                              // CustomLabel(
                              //   label: getText("ID", langCode),
                              //   required: true,
                              // ),
                              // const SizedBox(height: 6),
                              // CustomTextField(
                              //   controller: idController,
                              //   autovalidateMode: _autoValidateMode,
                              //   hint: getText("ID", langCode),
                              //   keyboardType: TextInputType.text,
                              //   validator: (value) {
                              //     if (value == null || value.isEmpty) {
                              //       return getText("ID is required", langCode);
                              //     }
                              //     return null;
                              //   },
                              // ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: fields.length,
                                itemBuilder: (context, index) {
                                  final field = fields[index];
                                  final label = field['label'];
                                  final translatedLabel =
                                      _translatedLabelsCache[label] ?? label;
                                  final items =
                                      field['translatedItems'] ??
                                      field['items'];

                                  // Init controllers if not exists
                                  fieldControllers.putIfAbsent(
                                    label,
                                    () => TextEditingController(),
                                  );

                                  fieldFocusNodes.putIfAbsent(label, () {
                                    final node = FocusNode();
                                    node.addListener(() {
                                      if (node.hasFocus) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              _scrollController.animateTo(
                                                _scrollController
                                                    .position
                                                    .maxScrollExtent,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                              );
                                            });
                                      }
                                    });
                                    return node;
                                  });

                                  return DynamicField(
                                    field: field,
                                    label: translatedLabel,
                                    items: items,
                                    controller: fieldControllers[label],
                                    focusNode: fieldFocusNodes[label],
                                    autovalidateMode: _autoValidateMode,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return getText(
                                          "{label} is required",
                                          args: {'label': translatedLabel},
                                          langCode,
                                        );
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Fixed Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: EffectButton(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _autoValidateMode =
                                      AutovalidateMode.onUserInteraction;
                                });
                                if (_formKey.currentState!.validate()) {
                                  handleAddLead(context, fields);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Config.activeButtonColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  getText("Add", langCode),
                                  style: TextStyle(
                                    color: Config.buttonTextColor,
                                    fontSize: Config.buttonTextFontSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: EffectButton(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                resetForm();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Config.deactiveButtonColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  getText("Reset", langCode),
                                  style: TextStyle(
                                    color: Config.buttonTextColor,
                                    fontSize: Config.buttonTextFontSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ProfileHostessPanel(controller: _profileController),
          ],
        ),
      ),
    );
  }
}
