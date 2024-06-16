import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_nitr/core/constants/app_constants.dart';
import 'package:hello_nitr/core/utils/image_compressor.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hello_nitr/models/user.dart';
import 'package:hello_nitr/models/login.dart';
import 'dart:convert';

class LocalStorageService {
  static Database? _database;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static final Logger _logger = Logger('LocalStorageService');

  // Get database instance or initialize if it doesn't exist
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create the user table in the database
  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.userTable} (
        empCode TEXT PRIMARY KEY,
        designation TEXT,
        departmentCode TEXT,
        departmentName TEXT,
        firstName TEXT,
        middleName TEXT,
        lastName TEXT,
        mobile TEXT,
        personalEmail TEXT,
        email TEXT,
        workPhone TEXT,
        residencePhone TEXT,
        quarterAlpha TEXT,
        quarterNo TEXT,
        employeeType TEXT,
        roomNo TEXT,
        photo TEXT
      )
    ''');
  }

  // Initialize the database
  static Future<void> initDatabase() async {
    await database;
  }

  // Save a user to the database
  static Future<void> saveUser(User user) async {
    final db = await database;
    //Compressing the image field before saving
    final compressedImage =
        ImageCompressor.compressBase64Image(user.photo!, quality: 50);
    //print the compressed image size and compression ratio

    _logger.info('Compression Details:');
    _logger.info('---------------------');
    _logger.info('Original Size: ${compressedImage['originalSize']} bytes');
    _logger.info('Compressed Size: ${compressedImage['compressedSize']} bytes');
    _logger.info(
        'Compression Ratio: ${compressedImage['compressionRatio'].toStringAsFixed(2)}%');
    _logger.info('Size Difference: ${compressedImage['sizeDifference']} bytes');
    _logger.info('---------------------');

    user.photo = compressedImage['compressedBase64Image'];
    await db.insert(
      AppConstants.userTable,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a user from the database by employee code
  static Future<User?> getUser(String empCode) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.userTable,
      where: 'empCode = ?',
      whereArgs: [empCode],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  // Delete a user from the database by employee code
  static Future<void> deleteUser(String empCode) async {
    final db = await database;
    await db.delete(
      AppConstants.userTable,
      where: 'empCode = ?',
      whereArgs: [empCode],
    );
  }

  // Save a list of users to the database
  static Future<void> saveUsers(List<User> contacts) async {
    final db = await database;
    final batch = db.batch();
    for (var user in contacts) {
      //Compressing the image field before saving
      final compressedImage =
          ImageCompressor.compressBase64Image(user.photo!, quality: 50);
      //print the compressed image size and compression ratio

      _logger.info('Compression Details:');
      _logger.info('---------------------');
      _logger.info('Original Size: ${compressedImage['originalSize']} bytes');
      _logger
          .info('Compressed Size: ${compressedImage['compressedSize']} bytes');
      _logger.info(
          'Compression Ratio: ${compressedImage['compressionRatio'].toStringAsFixed(2)}%');
      _logger
          .info('Size Difference: ${compressedImage['sizeDifference']} bytes');
      _logger.info('---------------------');

      user.photo = compressedImage['compressedBase64Image'];
      batch.insert(
        AppConstants.userTable,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  // Get all users from the database
  static Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query(AppConstants.userTable);
    return result.map((json) => User.fromJson(json)).toList();
  }

  // Get paginated contacts from the database
  static Future<List<User>> getPaginatedContacts(int offset, int limit,
      {bool ascending = true}) async {
    final db = await database;
    final orderBy = ascending ? 'ASC' : 'DESC';
    final result = await db.query(
      AppConstants.userTable,
      offset: offset,
      limit: limit,
      orderBy: 'firstName $orderBy',
    );
    return result.map((json) => User.fromJson(json)).toList();
  }

  // Search contacts in the database
  static Future<List<User>> searchContacts(String query, int offset, int limit,
      {bool ascending = true}) async {
    final db = await database;
    final orderBy = ascending ? 'ASC' : 'DESC';
    final result = await db.query(
      AppConstants.userTable,
      where:
          'firstName LIKE ? OR lastName LIKE ? OR mobile LIKE ? OR personalEmail LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%'],
      offset: offset,
      limit: limit,
      orderBy: 'firstName $orderBy',
    );
    return result.map((json) => User.fromJson(json)).toList();
  }

  // Search contacts by department in the database
  static Future<List<User>> searchContactsByDepartment(
      String query, String department, int offset, int limit,
      {bool ascending = true}) async {
    final db = await database;
    final orderBy = ascending ? 'ASC' : 'DESC';
    final result = await db.rawQuery('''
      SELECT * FROM ${AppConstants.userTable}
      WHERE (firstName || ' ' || IFNULL(middleName, '') || ' ' || lastName LIKE ? 
             OR mobile LIKE ? 
             OR personalEmail LIKE ? 
             OR email LIKE ?)
        AND departmentName = ?
      ORDER BY firstName $orderBy
      LIMIT ? OFFSET ?
    ''', [
      '%$query%',
      '%$query%',
      '%$query%',
      '%$query%',
      department,
      limit,
      offset
    ]);
    return result.map((json) => User.fromJson(json)).toList();
  }

  // Get unique departments from the database
  static Future<List<String>> getUniqueDepartments() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT departmentName FROM ${AppConstants.userTable} ORDER BY departmentName ASC');
    return result.map((row) => row['departmentName'] as String).toList();
  }

  // Get paginated users by employee type from the database
  static Future<List<User>> getPaginatedUsersByEmployeeType(
      String employeeType, int offset, int limit,
      {bool ascending = true}) async {
    final db = await database;
    final orderBy = ascending ? 'ASC' : 'DESC';
    final result = await db.query(
      AppConstants.userTable,
      where: 'employeeType = ?',
      whereArgs: [employeeType],
      offset: offset,
      limit: limit,
      orderBy: 'firstName $orderBy',
    );
    return result.map((json) => User.fromJson(json)).toList();
  }

  // Get paginated users by department from the database
  static Future<List<User>> getPaginatedUsersByDepartment(
      String departmentName, int offset, int limit,
      {bool ascending = true}) async {
    final db = await database;
    final orderBy = ascending ? 'ASC' : 'DESC';
    final result = await db.query(
      AppConstants.userTable,
      where: 'departmentName = ?',
      whereArgs: [departmentName],
      offset: offset,
      limit: limit,
      orderBy: 'firstName $orderBy',
    );
    return result.map((json) => User.fromJson(json)).toList();
  }

  // Sync contacts with the server
  static Future<void> syncContacts(List<User> serverUsers) async {
    final serverEmpCodes = serverUsers.map((user) => user.empCode).toSet();
    final localUsers = await getUsers();
    final localEmpCodes = localUsers.map((user) => user.empCode).toSet();

    // Delete users not in the server response
    final usersToDelete = localEmpCodes.difference(serverEmpCodes);
    for (final empCode in usersToDelete) {
      await deleteUser(empCode!);
    }

    // Save server users to the database
    await saveUsers(serverUsers);
  }

  // Save login response to secure storage
  static Future<void> saveLoginResponse(LoginResponse loginResponse) async {
    try {
      String loginJson = jsonEncode(loginResponse.toJson());
      await _secureStorage.write(
          key: AppConstants.currentLoggedInUserKey, value: loginJson);
    } catch (e) {
      _logger.severe('Error saving login response: $e');
    }
  }

  //Get login time from secure storage
  static Future<DateTime?> getLoginTime() async {
    try {
      String? loginJson =
          await _secureStorage.read(key: AppConstants.currentLoggedInUserKey);
      if (loginJson != null) {
        LoginResponse loginResponse =
            LoginResponse.fromJson(jsonDecode(loginJson));
        return loginResponse.loginTime;
      } else {
        return null;
      }
    } catch (e) {
      _logger.severe('Error retrieving login time: $e');
      return null;
    }
  }

  // Get login response from secure storage
  static Future<LoginResponse?> getLoginResponse() async {
    try {
      String? loginJson =
          await _secureStorage.read(key: AppConstants.currentLoggedInUserKey);
      if (loginJson != null) {
        return LoginResponse.fromJson(jsonDecode(loginJson));
      } else {
        return null;
      }
    } catch (e) {
      _logger.severe('Error retrieving login response: $e');
      return null;
    }
  }

  // Delete login response from secure storage
  static Future<void> deleteLoginResponse() async {
    try {
      await _secureStorage.delete(key: AppConstants.currentLoggedInUserKey);
    } catch (e) {
      _logger.severe('Error deleting login response: $e');
    }
  }

  // Save PIN to secure storage
  static Future<void> savePin(String pin) async {
    try {
      await _secureStorage.write(key: AppConstants.pinKey, value: pin);
    } catch (e) {
      _logger.severe('Error saving PIN: $e');
    }
  }

  // Get PIN from secure storage
  static Future<String?> getPin() async {
    try {
      return await _secureStorage.read(key: AppConstants.pinKey);
    } catch (e) {
      _logger.severe('Error retrieving PIN: $e');
      return null;
    }
  }

  // Delete PIN from secure storage
  static Future<void> deletePin() async {
    try {
      await _secureStorage.delete(key: AppConstants.pinKey);
    } catch (e) {
      _logger.severe('Error deleting PIN: $e');
    }
  }

  // Log out by deleting login response and PIN from secure storage
  static Future<void> logout() async {
    await deleteLoginResponse();
    await deletePin();
  }

  // Check if a user is logged in
  static Future<bool> checkIfUserIsLoggedIn() async {
    LoginResponse? currentUser = await getLoginResponse();
    return currentUser != null;
  }

  // Get the current user's name
  static Future<String?> getCurrentUserName() async {
    LoginResponse? currentUser = await getLoginResponse();
    return currentUser?.firstName;
  }

  // Get the current user
  static Future<User?> getCurrentUser() async {
    LoginResponse? currentUser = await getLoginResponse();
    return currentUser != null ? convertLoginResponseToUser(currentUser) : null;
  }

  // Get Total number of users in the database
  static Future<int> getTotalUsers() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.userTable}');
    return Sqflite.firstIntValue(result)!;
  }

  // get total number of users by employee type
  static Future<int> getTotalUsersByEmployeeType(String employeeType) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.userTable} WHERE employeeType = ?',
        [employeeType]);
    return Sqflite.firstIntValue(result)!;
  }

  // get total number of departments
  static Future<int> getTotalDepartments() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(DISTINCT departmentName) FROM ${AppConstants.userTable}');
    return Sqflite.firstIntValue(result)!;
  }

  // Convert a LoginResponse object to a User object
  static User convertLoginResponseToUser(LoginResponse loginResponse) {
    return User(
      empCode: loginResponse.empCode ?? '',
      designation: loginResponse.designation ?? '',
      departmentCode: loginResponse.departmentCode ?? '',
      departmentName: loginResponse.departmentName ?? '',
      firstName: loginResponse.firstName ?? '',
      middleName: loginResponse.middleName,
      lastName: loginResponse.lastName ?? '',
      mobile: loginResponse.mobile ?? '',
      personalEmail: loginResponse.personalEmail,
      email: loginResponse.email ?? '',
      workPhone: loginResponse.workPhone,
      residencePhone: loginResponse.residencePhone,
      quarterAlpha: loginResponse.quarterAlpha,
      quarterNo: loginResponse.quarterNo,
      employeeType: loginResponse.employeeType ?? '',
      roomNo: loginResponse.roomNo,
      photo: loginResponse.photo,
    );
  }

  // Save suggested contacts to secure storage
  static Future<void> saveSuggestedContacts(List<User> contacts) async {
    try {
      List<String> contactJsonList =
          contacts.map((contact) => jsonEncode(contact.toJson())).toList();
      await _secureStorage.write(
          key: AppConstants.suggestedContactsKey,
          value: jsonEncode(contactJsonList));
    } catch (e) {
      _logger.severe('Error saving suggested contacts: $e');
    }
  }

  // Load suggested contacts from secure storage
  static Future<List<User>> loadSuggestedContacts() async {
    try {
      String? contactJsonList =
          await _secureStorage.read(key: AppConstants.suggestedContactsKey);
      if (contactJsonList != null) {
        List<String> contactList =
            List<String>.from(jsonDecode(contactJsonList));
        return contactList
            .map((contactJson) => User.fromJson(jsonDecode(contactJson)))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      _logger.severe('Error loading suggested contacts: $e');
      return [];
    }
  }
}
