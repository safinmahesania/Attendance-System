import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class DatabaseHelper {
  static const databaseName = "certDB.db";
  static const databaseVersion = 1;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDatabase();
    return _db;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, databaseName);
    return await openDatabase(path,
        version: databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE membersInfo (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        age INTEGER NOT NULL,
        cnic TEXT NOT NULL,
        phoneNumber TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER NOT NULL PRIMARY KEY,
        day TEXT NOT NULL,
        date TEXT NOT NULL,
        memberId INTEGER NOT NULL,
        time TEXT NOT NULL,
        dutySpot TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE loginCred (
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE dutySpots (
        id INTEGER NOT NULL PRIMARY KEY,
        dutySpot TEXT NOT NULL
      )
    ''');
  }

  // CRUD operations
  Future<int> insert(Map<String, dynamic> row, String tableName) async {
    Database? db = await instance.db;
    return await db!.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    Database? db = await instance.db;
    return await db!.query(tableName);
  }

  Future<int> updateLoginPassword(String value) async {
    Database? db = await instance.db;
    return await db!.rawUpdate('''
    UPDATE loginCred
    SET password = ?
    WHERE username = "cert"
  ''', [value]);
  }

  Future<int> update(Map<String, dynamic> row, String tableName) async {
    Database? db = await instance.db;
    int id = row['id'];
    return await db!.update(tableName, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id, String tableName) async {
    Database? db = await instance.db;
    return await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addMembersInfo(Map<String, dynamic> data) async {
    Database? db = await instance.db;
    await db!.insert('membersInfo', data);
  }

  Future<List<String>> getAllMemberName() async {
    Database? db = await instance.db;
    List<Map<String, dynamic>> maps =
        await db!.query('membersInfo', columns: ['name']);
    final List<String> names = maps.map<String>((map) => map['name']).toList();
    return names;
  }

  Future<String> getAllMemberIdByName(String name) async {
    Database? db = await instance.db;
    String query = 'SELECT id FROM membersInfo WHERE name = ?';
    List<Map<String, dynamic>> maps = await db!.rawQuery(query, [name]);
    String id = maps[0]['id'].toString();
    return id;
  }

  Future<List<Map<String, dynamic>>> getMemberInfo(int id) async {
    const SQLQuery = 'SELECT * FROM membersInfo WHERE id = ?';
    Database? db = await instance.db;
    return await db!.rawQuery(SQLQuery, [id]);
  }

  Future<List<Map<String, dynamic>>> getAllMemberInfo() async {
    const SQLQuery = 'SELECT * FROM membersInfo';
    Database? db = await instance.db;
    return await db!.rawQuery(SQLQuery);
  }

  Future<List<int>> getAllMemberIds() async {
    Database? db = await instance.db;
    List<Map<String, dynamic>> maps =
        await db!.query('membersInfo', columns: ['id']);
    final List<int> ids = maps.map<int>((map) => map['id']).toList();
    return ids;
  }

  Future<List<String>> getAllDutySpots() async {
    Database? db = await instance.db;
    List<Map<String, dynamic>> maps =
        await db!.query('dutySpots', columns: ['dutySpot']);
    final List<String> dutySpot =
        maps.map<String>((map) => map['dutySpot']).toList();
    return dutySpot;
  }

  Future<void> addAttendance(Map<String, dynamic> data) async {
    Database? db = await instance.db;
    await db!.insert('attendance', data);
  }

  Future<List<Map<String, dynamic>>> getAllAttendance(
      String dateFrom, String dateTo, String name, String id) async {
    Database? db = await instance.db;
    if (name == 'All') {
      List<Map<String, dynamic>> data = await db!.query(
        'attendance',
        where: 'date >= ? AND date <= ?',
        whereArgs: [dateFrom, dateTo],
      );
      return data;
    } else {
      List<Map<String, dynamic>> data = await db!.query(
        'attendance',
        where: 'date >= ? AND date <= ? AND memberId = ?',
        whereArgs: [dateFrom, dateTo, id],
      );
      return data;
    }
  }

  Future<void> endShift(String timeOut, String date, String day) async {
    Database? db = await instance.db;
    await db!.update(
      'attendance',
      {'timeOut': timeOut},
      where: 'date = ? and day = ?',
      whereArgs: [date, day],
    );
  }

  Future<List<String>> getImages(String id) async {
    Database? db = await instance.db;
    final List<Map<String, dynamic>> maps =
        await db!.query('memberInfo', where: ('id = ?'), whereArgs: [id]);
    return List.generate(maps.length, (i) {
      return maps[i]['image'] as String;
    });
  }
}
/*INSERT INTO loginCred (username, password)
VALUES ("cert", "cert2023");
INSERT INTO membersInfo (id, name, position, age, cnic, phoneNumber)
VALUES (101, "Safin Mahesania", "Duty Incharge", 21, "42101-4453805-9", "03009535569");*/
//PERSON_NAME reported to duty spot at the DUTY_SPOT checkpoint at TIME.

/*
INSERT INTO dutySpots (id, dutySpot)
VALUES (1, "None");
INSERT INTO dutySpots (id, dutySpot)
VALUES (2, "Outside JK: Gents Desk");
INSERT INTO dutySpots (id, dutySpot)
VALUES (3, "Outside JK: Ladies Desk");
INSERT INTO dutySpots (id, dutySpot)
VALUES (4, "Inside JK: Gents Inside Gate");
INSERT INTO dutySpots (id, dutySpot)
VALUES (5, "Inside JK: Gents Rezgari");
INSERT INTO dutySpots (id, dutySpot)
VALUES (6, "Inside JK: Gents Senior");
INSERT INTO dutySpots (id, dutySpot)
VALUES (7, "Inside JK: MIC System");
INSERT INTO dutySpots (id, dutySpot)
VALUES (8, "Inside JK: REC");
INSERT INTO dutySpots (id, dutySpot)
VALUES (9, "Inside JK: Ladies Inside Gate");
INSERT INTO dutySpots (id, dutySpot)
VALUES (10, "Inside JK: Ladies Rezgari");
INSERT INTO dutySpots (id, dutySpot)
VALUES (11, "Inside JK: MiniJK");
INSERT INTO dutySpots (id, dutySpot)
VALUES (12, "Outside JK: Round");
INSERT INTO dutySpots (id, dutySpot)
VALUES (13, "Outside JK: Flag");
INSERT INTO dutySpots (id, dutySpot)
VALUES (14, "Outside JK: 412");
INSERT INTO dutySpots (id, dutySpot)
VALUES (15, "Outside JK: 612");
INSERT INTO dutySpots (id, dutySpot)
VALUES (16, "Outside JK: 403");
INSERT INTO dutySpots (id, dutySpot)
VALUES (17, "Outside JK: 603");
INSERT INTO dutySpots (id, dutySpot)
VALUES (18, "Double Duty");
INSERT INTO dutySpots (id, dutySpot)
VALUES (19, "Special Duty");*/
