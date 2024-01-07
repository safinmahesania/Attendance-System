// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:attendance/Reusable%20Code/button.dart';
import 'package:attendance/homeScreen.dart';
import 'package:flutter/material.dart';
import 'Reusable Code/textField.dart';
import 'changePassword.dart';
import 'database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  BuildContext? dialogContext;

  final snackBar = const SnackBar(
    content: Text(
      'Invalid username or password.',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    duration: Duration(milliseconds: 2000), // Adjust the duration as needed
    backgroundColor: Colors.green,
  );

  String getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String formatTimeWithLeadingZeros(DateTime time) {
    String hourString = time.hour.toString().padLeft(2, '0');
    String minuteString = time.minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }

  Future<void> delayOperation() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void login() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        },
      );
    });
    List<Map<String, dynamic>> row = await dbHelper.queryAllRows('loginCred');
    String username = row[0]['username'];
    String password = row[0]['password'];
    if (usernameTextController.text == username &&
        passwordTextController.text == password) {
      DateTime now = DateTime.now();
      String day = getDayOfWeek(now.weekday);
      String date = "${now.day}/${now.month}/${now.year}";
      String time = formatTimeWithLeadingZeros(now);
      delayOperation().then(
        (value) => {
          Navigator.pop(dialogContext!),
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                day: day,
                date: date,
                time: time,
              ),
            ),
          )
        },
      );
    } else {
      delayOperation().then(
        (value) => {
          Navigator.pop(dialogContext!),
          passwordTextController.clear(),
          ScaffoldMessenger.of(context).showSnackBar(snackBar),
        },
      );

      //displayErrorMotionToast(context, 'Invalid username or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //CERT Logo Image
              Image.asset(
                'assets/cert-logo.png',
                height: 250,
                width: 250,
              ),

              SizedBox(
                height: size.height * 0.05,
              ),

              //Email Text Field
              buildTextField(
                'Username',
                usernameTextController,
                false,
              ),

              //Password Text Field
              buildTextField(
                'Password',
                passwordTextController,
                true,
              ),

              //Login Button
              buildButton(
                'Login',
                context,
                () => {
                  login(),
                },
              ),

              //Change Password
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(seconds: 1),
                      transitionsBuilder:
                          (context, animation, animationTime, child) {
                        animation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastLinearToSlowEaseIn);
                        return ScaleTransition(
                          scale: animation,
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, animationTime) {
                        return const ChangePassword();
                      },
                    ),
                  );
                },
                child: const Text(
                  "Change Password?",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
