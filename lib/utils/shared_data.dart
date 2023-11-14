import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> sharedData() async {
  final prefs = await SharedPreferences.getInstance();
  var extractedUserData  = {};

  if(prefs.containsKey('userData')){
    extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
  }

  return extractedUserData;
}
