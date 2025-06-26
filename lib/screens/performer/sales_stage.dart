// Presentation Lead Detail Page : made by Leo on 2025/05/03

import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/model/lead_model.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:boostseller/widgets/dynamic_field.dart';
import 'dart:io';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:boostseller/widgets/custom_dropdown_normal.dart';
import 'package:boostseller/widgets/custom_comment.dart';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/widgets/custom_appbar.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class SalesStageScreen extends StatefulWidget {
  const SalesStageScreen({super.key});

  @override
  State<SalesStageScreen> createState() => _SalesStageScreenState();
}

class _SalesStageScreenState extends State<SalesStageScreen>
    with WidgetsBindingObserver {
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();
  final _formKey = GlobalKey<FormState>();
  final baseUrl = Config.realBackendURL;
  LeadModel? lead;
  List<Map<String, dynamic>> fields = [];
  Map<String, File> uploadFiles = {};
  final Map<String, TextEditingController> fieldControllers = {};
  final Map<String, FocusNode> fieldFocusNodes = {};
  final _scrollController = ScrollController();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  String _lastLangCode = '';
  bool _hasPreloadedTranslations = false;
  final Map<String, String> _translatedLabelsCache = {};
  String? _translatedName;
  String? _translatedStatus;
  String? _translatedInterest;
  List<Map<String, String>>? _translatedAdditionalInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String langCode = context.watch<LanguageProvider>().languageCode;
    if (lead == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      lead = args['lead'] as LeadModel;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        initializeData(lead!.stageId, langCode);
        _preloadTranslatedLabelsAndItems(fields, langCode);
      });
    }

    translateLeadDetails(langCode);
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
    if (!mounted) return;
    setState(() {
      _translatedName = translatedName;
      _translatedStatus = translatedStatus;
      _translatedInterest = translatedInterest;
      _translatedAdditionalInfo = translatedAdditionalInfo;
    });
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

  Future<void> initializeData(stageId, langCode) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    await Future.delayed(Duration.zero);
    loadingProvider.setLoading(true);
    try {
      await Future.wait([fetchFields(stageId, langCode)]);
    } catch (e) {
      ToastUtil.error(getText("data_load_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> fetchFields(stageId, langCode) async {
    final api = ApiService();
    try {
      final response = await api.post('/api/performer/lead/stage/fields', {
        'stageId': stageId,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        fields = List<Map<String, dynamic>>.from(jsonData['fields']);
        _preloadTranslatedLabelsAndItems(fields, langCode);
      } else {
        ToastUtil.error(getText("data_load_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    }
  }

  Future<void> closedLead(lead, reason, comment) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    final performerId = userProvider.user?.performer?.id;
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();
    loadingProvider.setLoading(true);
    try {
      final response = await api.post('/api/performer/lead/close', {
        'registerId': lead.registerId,
        'stageId': lead.stageId,
        'performerId': performerId,
        'reason': reason,
        'comment': comment,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(getText("Lead Successfully Closed!", langCode));
        NavigationService.pushReplacementNamed(
          '/lead-closed',
          arguments: {'stageId': jsonData['stageId']},
        );
      } else {
        ToastUtil.error(getText("submit_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  Future<void> nextStage(
    BuildContext context,
    List<Map<String, dynamic>> fields,
    lead,
  ) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final performerId = userProvider.user?.performer?.id;
    final formData = FormData();
    for (final field in fields) {
      final label = field['label'];
      final type = field['type'];

      final controller = fieldControllers[label];
      String value = controller?.text.trim() ?? '';

      // Handle file-based fields
      if (type == 'photo' || type == 'file' || type == 'camera') {
        final file = uploadFiles[label]; // <-- your map of picked files
        if (file != null) {
          formData.files.add(
            MapEntry(label, await MultipartFile.fromFile(file.path)),
          );
        }
      }

      formData.fields.add(MapEntry(label, value));
    }

    final leadRegisterId = lead.registerId;
    final stageId = lead.stageId;
    formData.fields.add(MapEntry('leadRegisterId', leadRegisterId));
    formData.fields.add(MapEntry('stageId', stageId));

    loadingProvider.setLoading(true);
    try {
      final api = ApiService();
      final response = await api.uploadFile(
        path: "/api/performer/lead/stage",
        formData: formData,
      );
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (!jsonData['final']) {
          ToastUtil.success(getText("move_next_Stage_message", langCode));
          lead.status = jsonData['nextStatus'];
          lead.stageId = jsonData['nextStageId'].toString();
          NavigationService.pushReplacementNamed(
            '/sales-stage',
            arguments: {
              'lead': lead,
              'key': ValueKey(jsonData['nextStageId'].toString()),
            },
          );
        } else {
          try {
            final response = await api.post('/api/performer/lead/complete', {
              'registerId': lead.registerId,
              'performerId': performerId,
            });
            Map<String, dynamic> jsonData = jsonDecode(response?.data);
            if ((response?.statusCode == 200 || response?.statusCode == 201) &&
                !jsonData['error']) {
              ToastUtil.success(
                getText("Lead Successfully Completed!", langCode),
              );
              NavigationService.pushReplacementNamed(
                '/lead-completed',
                arguments: {'interestId': lead.interestId},
              );
            } else {
              ToastUtil.error(getText("submit_error_message", langCode));
            }
          } catch (e) {
            debugPrint('Error: $e');
            ToastUtil.error(getText("ajax_error_message", langCode));
          }
        }
      } else {
        ToastUtil.error(getText("ajax_error_message", langCode));
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  void _showLeadInfoOverlay(BuildContext context, lead) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Close button
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => overlayEntry.remove(),
                        child: const Icon(
                          Icons.close,
                          color: Config.activeButtonColor,
                        ),
                      ),
                    ),

                    // Left-aligned content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          _translatedName ?? lead.name,
                          style: TextStyle(
                            fontSize: Config.leadNameFontSize,
                            fontWeight: FontWeight.bold,
                            color: Config.leadNameColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        _LeadInfoRow(
                          label: getText("Phone Number", langCode),
                          value: lead.phone,
                        ),
                        _LeadInfoRow(
                          label: getText("Interest", langCode),
                          value: _translatedInterest ?? lead.interest,
                        ),
                        // _LeadInfoRow(
                        //   label: getText("ID", langCode),
                        //   value: lead.idStr,
                        // ),
                        _LeadInfoRow(
                          label: getText("Register Date", langCode),
                          value: lead.date,
                        ),
                        ...?_translatedAdditionalInfo?.map((item) {
                          return _LeadInfoRow(
                            label: item['label'] ?? '',
                            value: item['value'] ?? '',
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
  }

  void showCloseReasonNotification(BuildContext context, lead) {
    final TextEditingController commentReasonController =
        TextEditingController();
    String? selectedReason;
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          // Adjust height when keyboard appears
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    // Close Icon
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Config.activeButtonColor,
                        ),
                      ),
                    ),

                    // Main Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            getText("Add reason & comment", langCode),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        CustomDropdownNormal(
                          hint: getText("Reason", langCode),
                          value: selectedReason,
                          items: ["Rejected", "Unqualified", "Deal closed"],
                          onChanged: (value) {
                            setModalState(() {
                              selectedReason = value;
                            });
                          },

                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),

                        const SizedBox(height: 16),

                        CustomMultilineTextField(
                          label: getText("Comment", langCode),
                          hintText: getText("comment_hint", langCode),
                          controller: commentReasonController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),

                        const SizedBox(height: 12),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: EffectButton(
                            onTap: () {
                              if (selectedReason == null ||
                                  selectedReason == '') {
                                ToastUtil.error(
                                  getText("reason_empty", langCode),
                                );
                              } else {
                                final comment =
                                    commentReasonController.text.trim();
                                if (comment == '') {
                                  ToastUtil.error(
                                    getText("comment_required", langCode),
                                  );
                                } else {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    _autoValidateMode =
                                        AutovalidateMode.onUserInteraction;
                                  });
                                  Navigator.pop(context);
                                  closedLead(lead, selectedReason, comment);
                                }
                              }
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
                                getText("Continue", langCode),
                                style: TextStyle(
                                  fontSize: Config.buttonTextFontSize,
                                  color: Config.buttonTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final LeadModel lead = args['lead'] as LeadModel;
    final loadingProvider = Provider.of<LoadingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String avatarPath = user?.avatarPath ?? '';
    final unreadCount = Provider.of<NotificationProvider>(context).unreadCount;
    String langCode = context.watch<LanguageProvider>().languageCode;
    if (!_hasPreloadedTranslations || _lastLangCode != langCode) {
      _preloadTranslatedLabelsAndItems(fields, langCode);
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: BackOverrideWrapper(
        onBack: () {
          FocusScope.of(context).unfocus();
          NavigationService.pushReplacementNamed('/performer-dashboard');
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Config.backgroundColor,
              resizeToAvoidBottomInset: true,
              appBar: CustomAppBar(
                unreadCount: unreadCount,
                avatarPath: avatarPath.isNotEmpty ? '$baseUrl$avatarPath' : '',
                onBackTap: () {
                  FocusScope.of(context).unfocus();
                  NavigationService.pushReplacementNamed(
                    '/performer-dashboard',
                  );
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Config.containerColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(lead, context),
                                  const SizedBox(height: 10),
                                  const Divider(
                                    color: Config.leadDivederColor,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 20),

                                  _buildForm(fields, langCode),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pinned bottom action buttons
                        _buildActions(context, lead),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            PerformerProfilePanel(controller: _profileController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(lead, BuildContext context) {
    String langCode = context.watch<LanguageProvider>().languageCode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _translatedName ?? lead.name,
              style: TextStyle(
                color: Config.leadNameColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
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
                  const SizedBox(width: 10), // Just 2px between badges
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
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
            SizedBox(width: 5),
            // Icon(Icons.info_outline, color: Color(0xFF1E90FF), size: 30),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Color(0xFF1E90FF),
                size: 30,
              ),
              onPressed: () {
                _showLeadInfoOverlay(context, lead);
              },
              splashRadius: 30, // Optional: size of ripple effect
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(fields, langCode) {
    return Form(
      key: _formKey,
      autovalidateMode: _autoValidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              final label = field['label'];
              final translatedLabel = _translatedLabelsCache[label] ?? label;
              final items = field['translatedItems'] ?? field['items'];
              // Init controllers/focus
              fieldControllers.putIfAbsent(
                label,
                () => TextEditingController(),
              );

              fieldFocusNodes.putIfAbsent(label, () {
                final node = FocusNode();
                node.addListener(() {
                  if (node.hasFocus) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
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
                  // if (field['required'] == true &&
                  //     (value == null || value.toString().isEmpty)) {
                  //   return getText(
                  //     "{label} is required",
                  //     args: {'label': translatedLabel},
                  //     langCode,
                  //   );
                  // }
                  if (value == null || value.isEmpty) {
                    return getText(
                      "{label} is required",
                      args: {'label': translatedLabel},
                      langCode,
                    );
                  }
                  return null;
                },
                onImagePicked: (file) {
                  setState(() {
                    uploadFiles[field['label']] = file;
                  });
                },
                onFilePicked: (file) {
                  setState(() {
                    uploadFiles[field['label']] = file;
                  });
                },

                onImageCaptured: (file) {
                  setState(() {
                    uploadFiles[field['label']] = file;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, lead) {
    String langCode = context.watch<LanguageProvider>().languageCode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          getText("Advance", langCode),
          Config.activeButtonColor,
          Config.buttonTextColor,
          () {
            FocusScope.of(context).unfocus();
            setState(() {
              _autoValidateMode = AutovalidateMode.onUserInteraction;
            });
            if (_formKey.currentState!.validate()) {
              nextStage(context, fields, lead);
            }
          },
        ),
        _actionButton(
          getText("Close", langCode),
          Config.deactiveButtonColor,
          Config.buttonTextColor,
          () {
            showCloseReasonNotification(context, lead);
          },
        ),
      ],
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

class _LeadInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _LeadInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$label : ",
          style: const TextStyle(color: Colors.white60, fontSize: 14),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
