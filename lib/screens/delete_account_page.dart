import 'package:get/get.dart';
import 'package:pay_lea_task/screens/login.dart';
import 'package:pay_lea_task/screens/screens.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'package:flutter/material.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        decoration: const BoxDecoration(
          color: Color(0xffeeeeee),
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              textAlign: TextAlign.center,
              '“Deleting your account will delete your access and all your information on this app. Are you sure you want to continue?”',
              style: TextStyle(
                wordSpacing: 5.0,
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Builder(
              builder: (context) {
                final GlobalKey<SlideActionState> key = GlobalKey();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SlideAction(
                    text: 'Slide to confirm',
                    sliderRotate: false,
                    key: key,
                    onSubmit: () async {
                      await deleteAccount(key, context);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  deleteAccount(GlobalKey<SlideActionState> key, BuildContext context) async {
    var uri = Uri.parse(
        '${globals.ofcRootUrl}DeleteAccount?UserId=${globals.userId}');
    var response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      key.currentState!.reset();
      Get.offAll(() => const MyLoginPage());
    } else {
      key.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    }
  }
}
