// web socket service :  made on by Leo on 2025/05/20

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/utils/translator_helper.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late BuildContext _context;
  late UserProvider _userProvider;
  late LanguageProvider _languageProvider;

  String _currentLang = 'en';

  void initContext(BuildContext context) {
    _context = context;
    _languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _currentLang = _languageProvider.languageCode;

    _languageProvider.addListener(() {
      _currentLang = _languageProvider.languageCode;
      print("Language changed to: $_currentLang");
    });
  }

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  final StreamController<dynamic> _leadNotificationController =
      StreamController.broadcast();

  Stream<dynamic> get leadNotifications => _leadNotificationController.stream;
  final AudioPlayer audioPlayer = AudioPlayer();

  IO.Socket? socket;

  void connect(String userId) {
    if (socket != null && socket!.connected) {
      print('Already connected');
      return;
    }

    socket = IO.io(
      Config.realBackendURL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) async {
      // String message =
      //     "You have been connected to the real-time service. Real-time notifications are available.";
      // String translated = await translatedMessage(message);
      // ToastUtil.info(translated);
      socket!.emit('register', userId);
    });

    socket?.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });

    socket?.onConnectError((err) {
      print('Connection error: $err');
    });

    socket?.on('lead_notification', (data) async {
      String translated = await translatedMessage(data['message']);
      print('Received lead notification: $data');
      // increase unread notification count
      Provider.of<NotificationProvider>(_context, listen: false).increment();
      ToastUtil.notification(translated);
      _leadNotificationController.add(data);
      audioPlayer.play(AssetSource('ding.mp3'));
    });

    socket?.on('lead_escalation', (data) async {
      String translated = await translatedMessage(data['message']);
      print('Received escalation lead notification: $data');
      // increase unread notification count
      Provider.of<NotificationProvider>(_context, listen: false).increment();

      ToastUtil.notification(translated);
      _leadNotificationController.add(data);
      audioPlayer.play(AssetSource('ding.mp3'));
    });

    socket?.on('lead_pendding', (data) async {
      String translated = await translatedMessage(data['message']);
      print('Received pendding lead notification: $data');
      // increase unread notification count
      Provider.of<NotificationProvider>(_context, listen: false).increment();
      ToastUtil.notification(translated);
      _leadNotificationController.add(data);
      audioPlayer.play(AssetSource('ding.mp3'));
    });

    socket?.on('approval_status_changed', (data) async {
      String translated = await translatedMessage(data['message']);
      print('Received approval status changed notification: $data');
      ToastUtil.notification(translated);
      audioPlayer.play(AssetSource('ding.mp3'));
      if (!data['approved']) {
        _userProvider.logout();
        disconnect();
      }
      Future.delayed(Duration(seconds: 3), () {
        NavigationService.pushReplacementNamed('/login');
      });
    });
  }

  void assignLead(Map<String, dynamic> leadData) {
    if (socket != null && socket!.connected) {
      socket?.emit('lead_added', leadData);
      print('Sending lead_added to socket...');
    } else {
      print('Socket not connected. Cannot send lead.');
    }
  }

  Future<String> translatedMessage(String message) async {
    final translated = await TranslatorHelper.translateText(
      message,
      _currentLang,
    );
    return translated;
  }

  void skipLead(Map<String, dynamic> data) {
    if (socket != null && socket!.connected) {
      socket?.emit('lead_skip', data);
      print(data);
    } else {
      print('Socket not connected. Cannot send lead.');
    }
  }

  void userRegister(Map<String, dynamic> userData) {
    if (socket != null && socket!.connected) {
      socket!.emit('user_register', userData);
      print('Emitted user_register with data: $userData');
    } else {
      print('Socket not connected. Cannot send user_register event.');
    }
  }

  void disconnect() {
    if (socket != null) {
      socket?.clearListeners(); // Remove all event listeners
      socket?.disconnect();
      socket?.destroy();
      socket = null;
    }
  }

  void dispose() {
    _leadNotificationController.close();
    socket?.disconnect();
  }
}
