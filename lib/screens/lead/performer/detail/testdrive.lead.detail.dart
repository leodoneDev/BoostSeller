import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/performer/profile.panel.dart';
import 'package:boostseller/widgets/button.effect.dart';

class TestDriveLeadDetailScreen extends StatefulWidget {
  const TestDriveLeadDetailScreen({super.key});

  @override
  State<TestDriveLeadDetailScreen> createState() =>
      _TestDriveLeadDetailScreenState();
}

class _TestDriveLeadDetailScreenState extends State<TestDriveLeadDetailScreen> {
  bool showedInterest = false;
  String? selectedTimes;
  String? selectedQuality = 'Functional';
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();
  final List<String> qualityOptions = [
    'Excellent',
    'Good',
    'Functional',
    'Minor Issue',
    'Major Issue',
    'Broken',
  ];
  final List<String> completedItems = [];
  final TextEditingController commentController = TextEditingController();
  final TextEditingController resultText1 = TextEditingController();
  final TextEditingController resultText2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF333333),
          appBar: AppBar(
            backgroundColor: const Color(0xFF3C3C3C),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF42A5F5),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _profileController.toggle(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset('assets/list.png', width: 24, height: 24),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _leadHeader(),
                            const SizedBox(height: 10),
                            const Divider(color: Colors.white30, height: 1),
                            const SizedBox(height: 20),
                            _checkboxRow(),
                            const SizedBox(height: 12),
                            _dropdownRow(),
                            const SizedBox(height: 12),
                            _qualityOptionsUI(),
                            const SizedBox(height: 12),
                            _completedItemsUI(),
                            const SizedBox(height: 12),
                            _fileInputsUI(),
                            const SizedBox(height: 12),
                            _photoDateInputs(),
                            const SizedBox(height: 12),
                            _commentInput(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pinned bottom action buttons
                  _actionButtons(),
                ],
              ),
            ),
          ),
        ),
        PerformerProfilePanel(controller: _profileController),
      ],
    );
  }

  Widget _leadHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Maxim",
              style: TextStyle(
                color: Colors.lightBlueAccent,
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
            Text(
              "Test Drive",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 20),
            Icon(Icons.info_outline, color: Color(0xFF1E90FF), size: 30),
          ],
        ),
      ],
    );
  }

  Widget _checkboxRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0), // No indent
          child: Row(
            children: [
              SizedBox(
                width: 24, // Checkbox default size
                height: 24,
                child: Checkbox(
                  value: showedInterest,
                  onChanged: (val) => setState(() => showedInterest = val!),
                  activeColor: Colors.lightBlueAccent,
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
      ],
    );
  }

  Widget _dropdownRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<String>(
            value: selectedTimes,
            hint: const Text("3", style: TextStyle(color: Colors.white)),
            dropdownColor: Colors.grey[800],
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            underline: const SizedBox(),
            items:
                ["1", "2", "3", "4", "5"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (val) => setState(() => selectedTimes = val),
          ),
        ),
        const SizedBox(width: 8),
        const Text("times test done", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _qualityOptionsUI() {
    return _buildGroupBox(
      title: "Quality",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(2, (colIndex) {
          // Get items for this column (3 per column)
          final items = qualityOptions.skip(colIndex * 3).take(3).toList();
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  items.map((opt) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: opt,
                          groupValue: selectedQuality,
                          onChanged:
                              (val) => setState(() => selectedQuality = val),
                          activeColor: Colors.lightBlueAccent,
                        ),
                        Flexible(
                          child: Text(
                            opt,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _completedItemsUI() {
    return _buildGroupBox(
      title: "Completed items",
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: List.generate(6, (i) {
          final item = "Item ${i + 1}";
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: completedItems.contains(item),
                onChanged: (val) {
                  setState(() {
                    val == true
                        ? completedItems.add(item)
                        : completedItems.remove(item);
                  });
                },
                activeColor: Colors.lightBlueAccent,
              ),
              Text(item, style: const TextStyle(color: Colors.white)),
            ],
          );
        }),
      ),
    );
  }

  Widget _fileInputsUI() {
    return _buildGroupBox(
      title: "Result",
      child: Column(
        children: [
          _fileInputRow("Manual document", Icons.edit),
          const SizedBox(height: 6),
          _fileInputRow("Image", Icons.edit),
        ],
      ),
    );
  }

  Widget _photoDateInputs() {
    return Column(
      children: [
        _fileInputRow("Photo", Icons.camera_alt_outlined),
        const SizedBox(height: 6),
        _fileInputRow("Date", Icons.calendar_today),
      ],
    );
  }

  Widget _fileInputRow(String hint, IconData icon) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: const UnderlineInputBorder(),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
          ),
        ),
        Icon(icon, color: Colors.white54),
      ],
    );
  }

  Widget _commentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Comment", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        TextField(
          maxLines: 4,
          controller: commentController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Comment",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[700],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton("Advance", const Color(0xFF1E90FF), Colors.white, () {}),
        _actionButton("Close", const Color(0xFF2A2A2A), Colors.white, () {}),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          // const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
