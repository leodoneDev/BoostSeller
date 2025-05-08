// Presentation Lead Detail Page : made by Leo on 2025/05/03

import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';

class PresentationLeadDetailScreen extends StatefulWidget {
  const PresentationLeadDetailScreen({super.key});

  @override
  State<PresentationLeadDetailScreen> createState() =>
      _PresentationLeadDetailScreenState();
}

class _PresentationLeadDetailScreenState
    extends State<PresentationLeadDetailScreen> {
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();
  bool _clientInterested = false;
  String _presentationSent = "Yes";

  void _showLeadInfoOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

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
                      children: const [
                        SizedBox(height: 10),
                        Text(
                          "Oleh",
                          style: TextStyle(
                            fontSize: Config.leadNameFontSize,
                            fontWeight: FontWeight.bold,
                            color: Config.leadNameColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        _LeadInfoRow(label: "Phone", value: "1-234-567-890"),
                        _LeadInfoRow(label: "Interest", value: "Interest 1"),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "Register",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "ID : 1234-1234-1234   ",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Date : 28/04/2025",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        _LeadInfoRow(label: "Gender", value: "Male"),
                        _LeadInfoRow(label: "Age", value: "38"),
                        _LeadInfoRow(label: "Budget", value: "\$500"),
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

  void showCloseReasonNotification(BuildContext context) {
    final TextEditingController commentReasonController =
        TextEditingController();
    String? selectedReason;

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
                        const Center(
                          child: Text(
                            "Add reason & comment",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Reason Dropdown
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: Colors.grey[800],
                              value: selectedReason,
                              hint: const Text(
                                "Reason",
                                style: TextStyle(color: Colors.white54),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white54,
                              ),
                              items:
                                  ["Rejected", "Unqualified", "Deal closed"]
                                      .map(
                                        (reason) => DropdownMenuItem(
                                          value: reason,
                                          child: Text(
                                            reason,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setModalState(() {
                                    selectedReason = val;
                                  }),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Comment Field
                        TextField(
                          controller: commentReasonController,
                          minLines: 1,
                          maxLines: null, // expands automatically
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Comment",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.grey[700],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: EffectButton(
                            onTap: () {
                              Navigator.pop(context);
                              _showCloseSuccessOverlay(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Config.activeButtonColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Add",
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

  void _showCloseSuccessOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
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
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => overlayEntry.remove(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(height: 20),
                          Text(
                            "Successfully Closed!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Now, you can work with other lead.\nPlease check and work on the list:\n“Assigned” and “In progress”",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
  }

  final TextEditingController mainCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Config.backgroundColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context, 'refresh'),
              splashRadius: 30,
              icon: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Config.activeButtonColor,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: Config.iconDefaultColor,
                ),
              ),
            ),
            actions: [
              EffectButton(
                onTap: () => _profileController.toggle(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset('assets/list.png', width: 24, height: 24),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                    top: 10,
                  ),
                  reverse: true, // ensures keyboard pushes UI up
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Config.containerColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 10),
                                  const Divider(
                                    color: Config.leadDivederColor,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: _buildForm(),
                                  ), // scrollable form
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Bottom Buttons (no space between form and buttons)
                          _buildActions(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        PerformerProfilePanel(controller: _profileController),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Maxim",
              style: TextStyle(
                color: Config.leadNameColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text("1234-1234-1235", style: TextStyle(color: Colors.white60)),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Presentation",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 20),
            // Icon(Icons.info_outline, color: Color(0xFF1E90FF), size: 30),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Color(0xFF1E90FF),
                size: 30,
              ),
              onPressed: () {
                _showLeadInfoOverlay(context);
              },
              splashRadius: 30, // Optional: size of ripple effect
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0), // No indent
          child: Row(
            children: [
              SizedBox(
                width: 24, // Checkbox default size
                height: 24,
                child: Checkbox(
                  value: _clientInterested,
                  onChanged: (val) => setState(() => _clientInterested = val!),
                  activeColor: Config.activeButtonColor,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Client showed interest",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.grey[800],
                  value: _presentationSent,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.white),
                  items:
                      ["Yes", "No"]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _presentationSent = val!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Presentation sent",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Comment", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: mainCommentController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Comment",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[700],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          "Advance",
          Config.activeButtonColor,
          Config.buttonTextColor,
          () {
            ToastUtil.success("Developing...");
          },
        ),
        _actionButton(
          "Close",
          Config.deactiveButtonColor,
          Config.buttonTextColor,
          () {
            showCloseReasonNotification(context);
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
