import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int unreadCount;
  final String avatarPath;
  final void Function() onBackTap;
  final void Function() onProfileTap;
  final void Function() onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.unreadCount,
    required this.avatarPath,
    required this.onBackTap,
    required this.onProfileTap,
    required this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    String langCode = languageProvider.languageCode;
    return AppBar(
      backgroundColor: Config.appbarColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: widget.onBackTap,
          child: Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Config.activeButtonColor,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back,
              size: Config.appBarBackIconSize,
              color: Config.iconDefaultColor,
            ),
          ),
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getText("Select Language", langCode),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // English Option
                            LanguageOption(
                              flag: '🇺🇸',
                              label: "English",
                              isSelected: languageProvider.languageCode == 'en',
                              onTap: () {
                                languageProvider.setLanguage('en');
                                Navigator.pop(context);
                              },
                            ),

                            const SizedBox(height: 12),

                            // Russian Option
                            LanguageOption(
                              flag: '🇷🇺',
                              label: "Русский",
                              isSelected: languageProvider.languageCode == 'ru',
                              onTap: () {
                                languageProvider.setLanguage('ru');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            },

            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Config.activeButtonColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.language,
                    size: 30,
                    color: Config.iconDefaultColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Notifications
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: widget.onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Config.activeButtonColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications,
                    size: 30,
                    color: Config.iconDefaultColor,
                  ),
                ),
                if (widget.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Config.notificationBadgeColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        widget.unreadCount > 99
                            ? '99+'
                            : widget.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Profile Avatar
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: widget.onProfileTap,
            child:
                widget.avatarPath.isNotEmpty
                    ? CircleAvatar(
                      radius: 17.5,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.avatarPath,
                      ),
                      backgroundColor: Colors.transparent,
                    )
                    : Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Config.activeButtonColor,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.account_circle,
                        size: Config.appBarIconSize,
                        color: Config.iconDefaultColor,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOption({
    super.key,
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Config.activeButtonColor : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Config.activeButtonColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
