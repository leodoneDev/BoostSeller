// Add Lead Success Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/hostess/profile.panel.dart';
import 'package:boostseller/constants.dart';

class AddSuccessScreen extends StatefulWidget {
  const AddSuccessScreen({super.key});

  @override
  State<AddSuccessScreen> createState() => _AddSuccessScreenState();
}

class _AddSuccessScreenState extends State<AddSuccessScreen> {
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.all(0),
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
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset('assets/logo.png', height: height * 0.2),
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: Config.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Config.titleFontColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Message
                    const Text(
                      'Your lead has been added\nsuccessfully!\n\nLet’s connect\nwith them soon!',
                      style: TextStyle(
                        fontSize: Config.subTitleFontSize,
                        color: Config.subTitleFontColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// ✅ Slide-out profile panel
        ProfileHostessPanel(controller: _profileController),
      ],
    );
  }
}
