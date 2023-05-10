import 'package:flutter_background/flutter_background.dart';

class BackgroundRun {
  Future<void> checkForBackground() async {
    bool hasPermissions = await FlutterBackground.hasPermissions;
    if (hasPermissions) {
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Task Manager",
        notificationText: "Fetching location",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
            name: 'taskmanager',
            defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );

      await FlutterBackground.initialize(androidConfig: androidConfig);
    }
  }
}
