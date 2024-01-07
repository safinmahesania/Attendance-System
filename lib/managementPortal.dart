import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:attendance/loginScreen.dart';
import 'package:intl/intl.dart';
import 'database.dart';

class ManagementPortal extends StatefulWidget {
  const ManagementPortal({super.key});

  @override
  State<ManagementPortal> createState() => _ManagementPortalState();
}

class _ManagementPortalState extends State<ManagementPortal> {
  final dbHelper = DatabaseHelper.instance;

  int currentIndex = 0;
  DateTime selectedFromDate = DateTime.now();
  String dateTo = '';
  String dateFrom = '';
  DateTime selectedToDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  List<String> items = ['All'];
  String names = 'All';
  double dutyCount = 0;

  final List<List<String>> attendanceTableData = [
    ['SNo.', 'Day', 'Date', 'Name', 'Duty Spot', 'Time In', 'Time Out'],
  ];

  void getAttendanceData(String dateFrom, String dateTo, String name) async {
    String id = '';
    double count = 0;
    if (name != 'All') {
      id = await dbHelper.getAllMemberIdByName(name);
    }
    List<Map<String, dynamic>> data =
        await dbHelper.getAllAttendance(dateFrom, dateTo, name, id);
    for (int i = 0; i < data.length; i++) {
      List<Map<String, dynamic>> temp =
          await dbHelper.getMemberInfo(data[i]['memberId']);
      String name = temp[0]['name'];
      String timeOut = '';
      if (data[i]['timeOut'] != null) {
        timeOut = data[i]['timeOut'];
      }

      if (data[i]['dutySpot'] == 'Double Duty') {
        count = count + 0.5;
      } else {
        count = count + 1;
      }
      setState(() {
        dutyCount = count;
        attendanceTableData.add([
          (i + 1).toString(),
          data[i]['day'],
          data[i]['date'],
          name,
          data[i]['dutySpot'],
          data[i]['timeIn'],
          timeOut,
        ]);
      });
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedFromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedFromDate) {
      setState(() {
        selectedFromDate = picked;
        dateFrom =
            "${selectedFromDate.day}/${selectedFromDate.month}/${selectedFromDate.year}";
      });
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedToDate) {
      setState(() {
        selectedToDate = picked;
        dateTo =
            "${selectedToDate.day}/${selectedToDate.month}/${selectedToDate.year}";
      });
    }
  }

  void getMembersName() async {
    List<String> data = await dbHelper.getAllMemberName();
    List<String> name = ['All'];
    for (int i = 0; i < data.length; i++) {
      name.add(data[i]);
    }
    setState(() {
      items = name;
    });
  }

  //MembersInfo
  final List<List<String>> membersInfoTableData = [
    ['ID', 'Name', 'Position', 'Age', 'CNIC', 'Phone Number'],
  ];

  void getMemberInfo() async {
    List<Map<String, dynamic>> data = await dbHelper.getAllMemberInfo();
    for (int i = 0; i < data.length; i++) {
      int age = dobToAge(
        data[i]['dob'],
      );
      setState(() {
        membersInfoTableData.add([
          data[i]['id'].toString(),
          data[i]['name'],
          data[i]['position'],
          age.toString(),
          data[i]['cnic'],
          data[i]['phoneNumber'],
        ]);
      });
    }
  }

  //Add Member
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController =
      TextEditingController();
  TextEditingController cnicTextEditingController = TextEditingController();
  TextEditingController positionTextEditingController = TextEditingController();
  TextEditingController dobTextEditingController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String date = '';
  int idToDisplay = 0;

  File? imageFile;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        date = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
  }

  Widget buildTextField(
    TextEditingController textEditingController,
    String labelText,
    Size size,
  ) {
    return SizedBox(
      height: 40,
      width: size.width * 0.2,
      child: TextFormField(
        controller: textEditingController,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Colors.green,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
              width: 1.0,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
              width: 1.0,
            ),
          ),
          prefixIcon: const Icon(
            Icons.person,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  void getID() async {
    List<int> ids = await dbHelper.getAllMemberIds();
    if (ids.isEmpty) {
      setState(() {
        idToDisplay = 101;
      });
    } else {
      setState(() {
        idToDisplay = ids.last + 1;
      });
    }
  }

  //DOB to Age Converter
  int dobToAge(String dobString) {
    // Parse the DOB string into a DateTime object
    DateTime dob = dateFormat.parse(dobString);

    // Get the current date
    DateTime now = DateTime.now();

    // Calculate the age
    int age = now.year - dob.year;

    // Check if the birthday hasn't occurred yet this year
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    setState(() {
      dateTo =
          "${selectedToDate.day}/${selectedToDate.month}/${selectedToDate.year}";
      dateFrom =
          "${selectedFromDate.day}/${selectedFromDate.month}/${selectedFromDate.year}";
    });
    getMembersName();
    getAttendanceData(dateFrom, dateTo, names);
    getMemberInfo();
    getID();
    super.initState();
  }

  Widget getPage(int index, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    switch (index) {
      case 0:
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'From ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dateFormat.format(selectedFromDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => selectFromDate(context),
                          child: const Text('Select Date'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'To ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dateFormat.format(selectedToDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => selectToDate(context),
                          child: const Text('Select Date'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Member ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                              value: names,
                              onChanged: (newValue) {
                                setState(() {
                                  names = newValue!;
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
                    ElevatedButton(
                      onPressed: () => {
                        attendanceTableData.removeRange(
                          1,
                          attendanceTableData.length,
                        ),
                        getAttendanceData(dateFrom, dateTo, names),
                      },
                      child: const Text('Filter'),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                SizedBox(
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
                SizedBox(
                  height: size.height * 0.03,
                ),
                SizedBox(
                  width: size.width * 0.95,
                  child: Row(
                    children: [
                      const Text(
                        "Total Attendance: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dutyCount.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      case 1:
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: size.width * 0.95,
              child: DataTable(
                border: TableBorder.all(),
                columns: List.generate(
                  membersInfoTableData[0].length,
                  (index) => DataColumn(
                    label: Text(
                      membersInfoTableData[0][index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                rows: List.generate(
                  membersInfoTableData.length - 1, // Exclude the header row
                  (rowIndex) {
                    return DataRow(
                      cells: List.generate(
                        membersInfoTableData[rowIndex + 1].length,
                        (colIndex) {
                          return DataCell(
                            Text(
                              membersInfoTableData[rowIndex + 1][colIndex],
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
        );
      case 2:
        return Container(
          //padding: const EdgeInsets.all(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Member ID: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        idToDisplay.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  /*SizedBox(
                    height: size.height * 0.03,
                  ),*/
                  buildTextField(
                    nameTextEditingController,
                    'Full Name',
                    size,
                  ),
                  /*SizedBox(
                    height: size.height * 0.03,
                  ),*/
                  buildTextField(
                    positionTextEditingController,
                    'Position',
                    size,
                  ),
                  /*SizedBox(
                    height: size.height * 0.03,
                  ),*/
                  /*buildTextField(
                    dobTextEditingController,
                    'Age',
                    size,
                  ),*/
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            dateFormat.format(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () => selectFromDate(context),
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  /*SizedBox(
                    height: size.height * 0.03,
                  ),*/
                  buildTextField(
                    cnicTextEditingController,
                    'CNIC',
                    size,
                  ),
                  /*SizedBox(
                    height: size.height * 0.03,
                  ),*/
                  buildTextField(
                    phoneNumberTextEditingController,
                    'Phone Number',
                    size,
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: size.height * 0.175,
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                      color: Colors.black.withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                        )
                      ],
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    /**/
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.file(
                              imageFile!,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      pickImage();
                    },
                    child: const Text(
                      textAlign: TextAlign.center,
                      "Upload Image",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.2,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (imageFile != null) {
                        final imagePath = imageFile!.path;
                        await dbHelper.addMembersInfo({
                          'id': idToDisplay,
                          'name': nameTextEditingController.text,
                          'position': positionTextEditingController.text,
                          'dob': date,
                          'cnic': cnicTextEditingController.text,
                          'phoneNumber': phoneNumberTextEditingController.text,
                          'image': imagePath,
                        });

                        setState(() {
                          membersInfoTableData.add([
                            idToDisplay.toString(),
                            nameTextEditingController.text,
                            positionTextEditingController.text,
                            dobToAge(date).toString(),
                            cnicTextEditingController.text,
                            phoneNumberTextEditingController.text,
                          ]);
                          getID();
                          nameTextEditingController.clear();
                          positionTextEditingController.clear();
                          cnicTextEditingController.clear();
                          phoneNumberTextEditingController.clear();
                          imageFile = null;
                          date =
                              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
                        });
                      }
                    },
                    child: const Text(
                      'Add Member',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      default:
        return const Text('Unknown Page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Community Emergency Response Team Management Portal',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: getPage(
        currentIndex,
        context,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Attendance Sheet',
            icon: Icon(
              Icons.bar_chart,
              color: Colors.green,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Members Information',
            icon: Icon(
              Icons.person_2,
              color: Colors.green,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Add Member',
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
