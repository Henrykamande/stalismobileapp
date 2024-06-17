import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/utils/http.dart';

class UserLogin with ChangeNotifier {
  bool isLoggedIn = false;
  bool _isAuthenticated = false;

  Future<dynamic> loginApi(String password, String email) async {
    try {
      // var url = onlineBackendUrl;
     final dio = Dio();
      var url = 'https://prestige-nhg7.onrender.com';

      var response = await dio
          .post('$url/login', data: {'email': email, 'password': password});

      // print(' login response ${response.data}');
      // var details = {'email': email, 'password': password};
      // final loginData = jsonEncode(details);
      //
      // final response = await httpPost('login', loginData);

      // var authData = jsonDecode(response);

     var authData = response.data;

      if (authData['ResultCode'] == 1200) {

        var token = authData['ResponseData']['authToken'];
        SharedPreferences prefs = await SharedPreferences.getInstance();

        print(' auth data store id ${authData['ResponseData']['store_id']}');

        final userData = jsonEncode({
          'token': token,
          'userId': authData['ResponseData']['user_id'],
          'name': authData['ResponseData']['name'],
          'userName': authData['ResponseData']['name'],
          'subscriberId': authData['ResponseData']['subscriber_id'],
          'storeId': authData['ResponseData']['store_id'],
          'storeName': authData['ResponseData']['shopName'],
          'role': 1,
        });

        _isAuthenticated = true;
        isLoggedIn = true;

        prefs.setBool('isAuthenticated', true);
        prefs.setBool('isLoggedIn ', true);
        prefs.setString('userData', userData);
        prefs.setString('name', authData['ResponseData']['userName']);

        notifyListeners();
        return {'ResultCode': 1200, 'message': 'Login Successful'};
      } else {
        return {'ResultCode': 1500, 'message': authData['ResultDesc']};
      }
    } catch (error) {
      return {'ResultCode': 1500, 'message': error.toString()};
    }
  }
}
