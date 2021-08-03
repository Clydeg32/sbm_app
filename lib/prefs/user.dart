import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  static get(key) async {
    var prefs = await SharedPreferences.getInstance();

    var userString = prefs.getString('user');

    if (userString == null) {
      return '';
    }
    var user = jsonDecode(userString);
    return user[key] ?? '';
  }
}