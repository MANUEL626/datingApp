import 'services/db.dart';

final dbHelper = DatabaseHelper.instance;

var user_id;
bool connect = false;
Map<String, dynamic> userInfo = {};