// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:attendance/Reusable%20Code/toasts.dart';
import 'package:attendance/managementPortal.dart';
import 'package:flutter/material.dart';
import 'Reusable Code/button.dart';
import 'Reusable Code/logMessage.dart';
import 'Reusable Code/textField.dart';
import 'database.dart';
import 'loginScreen.dart';

class HomeScreen extends StatefulWidget {
  final String time;
  final String date;
  final String day;

  const HomeScreen({
    super.key,
    required this.time,
    required this.date,
    required this.day,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController idTextEditingController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  String memberName = "";
  String memberPosition = "";
  String dutyTime = "";
  String memberId = "";

  List<String> items = ['None'];
  String dutySpot = 'None';

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

  void getDutySpots() async {
    List<String> spots = await dbHelper.getAllDutySpots();
    setState(() {
      items = spots;
    });
  }

  String formatTimeWithLeadingZeros(DateTime time) {
    String hourString = time.hour.toString().padLeft(2, '0');
    String minuteString = time.minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }

  //Logs
  List<String> logMessages = [];

  //Attendance Sheet
  final List<List<String>> attendanceTableData = [
    ['Name', 'Duty Spot', 'Time In', 'Time Out'],
  ];

  //Management
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  BuildContext? dialogContext;
  File? imageFile;

  Future<void> delayOperation() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  final snackBar = const SnackBar(
    content: Text(
      'Invalid username or password.',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    duration: Duration(milliseconds: 2000),
    backgroundColor: Colors.green,
  );

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
    String username = row[1]['username'];
    String password = row[1]['password'];
    if (usernameTextController.text == username &&
        passwordTextController.text == password) {
      delayOperation().then(
        (value) => {
          Navigator.pop(dialogContext!),
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ManagementPortal(),
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
    }
  }

  @override
  void initState() {
    getDutySpots();
    logMessages.add(
        ' *** Login into the system on ${widget.day}, ${widget.date} at ${widget.time}.');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*Image.asset(
                'assets/cert-logo.png',
                height: 50,
                width: 50,
              ),*/
              SizedBox(width: size.width * 0.01),
              const Text(
                'Al Azhar Garden Community Emergency Response Team',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: const TabBar(
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Logs'),
              Tab(text: 'Attendance Sheet'),
              Tab(text: 'Management'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              color: Colors.white10,
              padding: const EdgeInsets.only(
                left: 100,
                right: 100,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Enter Membership ID: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 200,
                          ),
                          child: TextField(
                            obscureText: false,
                            enabled: true,
                            decoration: const InputDecoration(
                              filled: false,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              fillColor: Colors.black45,
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              height: 0.75,
                            ),
                            autofocus: false,
                            controller: idTextEditingController,
                            keyboardType: TextInputType.none,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.025,
                        ),
                        Container(
                          height: 40,
                          width: 160,
                          //margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              bool idExists = false;
                              List<int> ids = await dbHelper.getAllMemberIds();
                              print(ids);
                              for (int i = 0; i < ids.length; i++) {
                                if (ids[i] ==
                                    int.parse(idTextEditingController.text)) {
                                  idExists = true;
                                }
                              }
                              if (idExists == true) {
                                List<Map<String, dynamic>> data =
                                    await dbHelper.getMemberInfo(
                                  int.parse(idTextEditingController.text),
                                );
                                setState(() {
                                  imageFile = File(data[0]['image']);
                                  memberName = data[0]['name'];
                                  memberId = idTextEditingController.text;
                                  memberPosition = data[0]['position'];
                                  DateTime time = DateTime.now();
                                  dutyTime = formatTimeWithLeadingZeros(time);
                                  idTextEditingController.text = "";
                                });
                              } else {
                                displayErrorMotionToast(
                                    context, 'Invalid Member ID!');
                                setState(() {
                                  imageFile = null;
                                  memberName = "";
                                  memberId = "";
                                  memberPosition = "";
                                  dutyTime = "";
                                  idTextEditingController.text = "";
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.lightGreen;
                                }
                                return Colors.green;
                              }),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      children: [
                        imageFile != null
                            ? Image.file(
                                imageFile!,
                                height: 150,
                                width: 150,
                              )
                            : Image.asset(
                                'assets/profile.jpg',
                                height: 150,
                                width: 150,
                              ),
                        SizedBox(
                          width: size.width * 0.025,
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Membership ID: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      memberId,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Name: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    memberName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Position ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    memberPosition,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.225,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Time In: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  dutyTime,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Duty Spot: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  height: 35,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      alignment: Alignment.center,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(30),
                                      ),
                                      isExpanded: true,
                                      focusColor: Colors.white,
                                      value: dutySpot,
                                      onChanged: (newValue) {
                                        setState(() {
                                          dutySpot = newValue!;
                                        });
                                      },
                                      items: items.map((item) {
                                        return DropdownMenuItem(
                                          alignment: Alignment.center,
                                          value: item,
                                          child: Text(
                                            item,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 22,
                            ),
                            Container(
                              height: 30,
                              width: 150,
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(90),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (dutyTime != "") {
                                    DateTime now = DateTime.now();
                                    String date =
                                        "${now.day}/${now.month}/${now.year}";
                                    String day = getDayOfWeek(now.weekday);
                                    dbHelper.addAttendance({
                                      'day': day,
                                      'date': date,
                                      'memberId': memberId,
                                      'dutySpot': dutySpot,
                                      'timeIn': dutyTime,
                                    });
                                    setState(() {
                                      attendanceTableData.add([
                                        memberName,
                                        dutySpot,
                                        dutyTime,
                                        '-'
                                      ]);
                                      logMessages.insert(0,
                                          " *** $memberName reported to duty spot at the $dutySpot checkpoint at $dutyTime.");
                                      memberName = "";
                                      memberId = "";
                                      memberPosition = "";
                                      dutyTime = "";
                                      idTextEditingController.text = "";
                                      dutySpot = 'None';
                                    });
                                  } else {
                                    displayErrorMotionToast(
                                        context, 'Invalid data!');
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.lightGreen;
                                    }
                                    return Colors.green;
                                  }),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 150,
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90),
                            border: Border.all(
                              color: Colors.green,
                              style: BorderStyle.solid,
                              width: 2.5,
                            )),
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime now = DateTime.now();
                            String day = getDayOfWeek(now.weekday);
                            String date = "${now.day}/${now.month}/${now.year}";
                            String timeOut = formatTimeWithLeadingZeros(now);
                            await dbHelper.endShift(timeOut, date, day);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            elevation:
                                MaterialStateProperty.resolveWith<double>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return 0;
                                }
                                return 0; // Defer to the widget's default.
                              },
                            ),
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.lightGreen;
                              }
                              return Colors.transparent;
                            }),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          child: const Text(
                            'End Shift',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListView.builder(
              itemCount: logMessages.length,
              itemBuilder: (context, index) {
                return buildLogMessage(logMessages[index]);
              },
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: size.width * 0.95,
                  child: DataTable(
                    border: TableBorder.all(),
                    columns: List.generate(
                      attendanceTableData[0].length,
                      (index) => DataColumn(
                        label: Text(
                          attendanceTableData[0][index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    rows: List.generate(
                      attendanceTableData.length - 1, // Exclude the header row
                      (rowIndex) {
                        return DataRow(
                          cells: List.generate(
                            attendanceTableData[rowIndex + 1].length,
                            (colIndex) {
                              return DataCell(
                                Text(
                                  attendanceTableData[rowIndex + 1][colIndex],
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //CERT Logo Image
                    const Text(
                      'Management Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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
                      login()
                      },
                    ),

                    //Change Password
                    GestureDetector(
                      onTap: () {},
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
          ],
        ),
      ),
    );
  }
}
