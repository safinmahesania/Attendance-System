// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:attendance/loginScreen.dart';
import 'package:flutter/material.dart';
import 'Reusable Code/button.dart';
import 'Reusable Code/textField.dart';
import 'Reusable Code/toasts.dart';
import 'database.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController currentPasswordTextController = TextEditingController();
  TextEditingController newPasswordTextController = TextEditingController();
  TextEditingController confirmNewPasswordTextController =
      TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  BuildContext? dialogContext;

  Future<void> delayOperation() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Simulate a 2-second delay
  }

  final snackBar = const SnackBar(
    content: Text(
      'Password changed successfully!',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    duration: Duration(milliseconds: 2000), // Adjust the duration as needed
    backgroundColor: Colors.green,
  );

  void changePassword() async {
    List<Map<String, dynamic>> row = await dbHelper.queryAllRows('loginCred');
    //String username = row[0]['username'];
    String password = row[0]['password'];
    if (currentPasswordTextController.text == password &&
        newPasswordTextController.text ==
            confirmNewPasswordTextController.text) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      dbHelper.updateLoginPassword(newPasswordTextController.text);
      delayOperation().then(
        (value) => {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
        },
      );
    } else if (currentPasswordTextController.text != password) {
      displayErrorMotionToast(context, 'Current password is incorrect!');
    } else if (newPasswordTextController.text !=
        confirmNewPasswordTextController.text) {
      displayErrorMotionToast(context, 'Confirm new password is incorrect!');
    } else {
      displayErrorMotionToast(context, 'Error occurred retry!');
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

              //Current Passowrd Text Field
              buildTextField(
                'Current Password',
                currentPasswordTextController,
                true,
              ),

              //New Password Text Field
              buildTextField(
                'New Password',
                newPasswordTextController,
                true,
              ),

              //Confirm New Password Text Field
              buildTextField(
                'Confirm New Password',
                confirmNewPasswordTextController,
                true,
              ),

              //Change Password Button
              buildButton(
                'Change Password',
                context,
                () => {
                  changePassword(),
                },
              ),

              //Go back to Login
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
                        return const LoginScreen();
                      },
                    ),
                  );
                },
                child: const Text(
                  "Back to Login",
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
