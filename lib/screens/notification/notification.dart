import 'package:flutter/material.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/model/notification.dart';
import 'package:boostseller/screens/profile/performer/profile_panel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ProfilePerformerPanelController _profileController =
      ProfilePerformerPanelController();
  List<NotificationModel> notifications = [
    NotificationModel(
      title: 'New Offer',
      message: '50% off for all electronics today only.',
      timestamp: 'Just now',
      isRead: false,
    ),
    NotificationModel(
      title: 'Order Confirmed',
      message: 'Your order #2349 has been placed.',
      timestamp: '2h ago',
      isRead: true,
    ),
    NotificationModel(
      title: 'Weekly Update',
      message: 'Here is your weekly report for activity.',
      timestamp: '1d ago',
      isRead: false,
    ),
  ];

  void markAsRead(int index) {
    setState(() {
      notifications[index].isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              padding: const EdgeInsets.all(0),
              icon: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Config.activeButtonColor, // light blue
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: Config.iconDefaultColor,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_active,
                  size: 35,
                  color: Config.iconDefaultColor,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  size: 35,
                  color: Config.iconDefaultColor,
                ),
                onPressed: () {
                  _profileController.toggle();
                },
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              return GestureDetector(
                onTap: () => markAsRead(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:
                        item.isRead
                            ? const Color(0xFF2C2C3A)
                            : const Color(0xFF3A3A4D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: item.isRead ? Colors.grey : Colors.amberAccent,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            item.isRead ? FontWeight.w400 : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      item.message,
                      style: TextStyle(color: Colors.grey[300], fontSize: 14),
                    ),
                    trailing: Text(
                      item.timestamp,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        PerformerProfilePanel(controller: _profileController),
      ],
    );
  }
}
