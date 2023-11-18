import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/utils/http.dart';

class UserLogin with ChangeNotifier {
  bool isLoggedIn = false;


  Future<dynamic> authenticateUser(String email, String password) async {
    try {
      final PrefService _prefs = PrefService();

      final loginData = jsonEncode({'email': email, 'password': password});
      final response = await httpPost('login', loginData);
      var authData = jsonDecode(response.body);

      if (authData['ResultCode'] == 1200) {
        var token = authData['ResponseData']['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();

        final userData = jsonEncode({
          'token': token,
          'name': authData['ResponseData']['name'],
          'role': 1,
          'storeId': authData['ResponseData']['store_id'],
          'storeName': authData['ResponseData']['storename']
        });

        isLoggedIn = true;
        prefs.setBool('isAuthenticated', true);
        prefs.setString('userData', userData);
        prefs.setString('name', authData['ResponseData']['name']);

        int storeid = authData['ResponseData']['store_id'];
        String storename = authData['ResponseData']['storename'];
        String logineduserName = authData['ResponseData']['name'];
        _prefs.createCache(token, storeid.toString(), logineduserName, storename);

        notifyListeners();
        return {'ResultCode': 1200, 'message': 'Login Successful'};
      } else {
        return {'ResultCode': 1500, 'message': authData['ResultDesc']};
      }
    } catch (error) {
      print(error.toString());
      return {'ResultCode': 1500, 'message': error.toString()};
    }
  }

}
