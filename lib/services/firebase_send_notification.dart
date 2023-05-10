import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SendNotification extends ChangeNotifier {
  static AndroidNotificationChannel? channel;
  static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  static Future init() async {
    //  getToken();
    loadFCM();
    listenFCM();
  }

  static loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
        showBadge: true,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(channel!);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = message.notification!.android!;
      flutterLocalNotificationsPlugin!.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(channel!.id, channel!.name,
              icon: 'ic_launcher',
              priority: Priority.max,
              importance: Importance.max,
              channelShowBadge: true,
              autoCancel: false),
        ),
      );
    });
  }

  static Future<String> getToken() async {
    var name = "";
    // var collection =
    //     FirebaseFirestore.instance.collection(globals.databaseName);
    // var docSnapshot = await collection.doc(globals.userId.toString()).get();

    // if (docSnapshot.exists) {
    //   Map<String, dynamic> data = docSnapshot.data();
    //   name = data['Id[${globals.userId.toString()}]'];
    // }

    await FirebaseMessaging.instance.getToken().then((token) {
      // if (name != token) {
      //   Map<String, dynamic> data = {"Id[${globals.userId}]": token};
      //   FirebaseFirestore.instance
      //       .collection(globals.databaseName)
      //       .doc(globals.userId.toString())
      //       .set(data, SetOptions(merge: true));
      // }
      name = token!;
      print(token);
    });
    return name;
  }

  // static sendMessage(
  //     String colname, String docname, String body, String title) async {
  //   var name = "";
  //   var collection = FirebaseFirestore.instance.collection(colname);
  //   var docSnapshot = await collection.doc(docname).get();
  //   if (docSnapshot.exists) {
  //     Map<String, dynamic> data = docSnapshot.data();
  //     name = data['Id[$docname]'];
  //   }

  //   try {
  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //         'Authorization':
  //             'key=AAAAt4YTR3E:APA91bEJKwWEQdPPKgSbXVpsuVpZYLeY_-06JByPYQX3F0DKzq2CZzcawBe_3ScSn5xmmq3thCh9rk9DI7TVOt-zozrHEC2oJZctpKf_rPRHeZnHBPqcn0XvyH8kXzu0HQHUfZUJ9Yz9',
  //       },
  //       body: jsonEncode(
  //         <String, dynamic>{
  //           'notification': <String, dynamic>{
  //             'title': "Leave Manager",
  //             'body': body
  //           },
  //           'priority': 'high',
  //           'data': <String, dynamic>{
  //             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //             // 'id': '1',
  //             'status': 'done',
  //           },
  //           'to': name
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
