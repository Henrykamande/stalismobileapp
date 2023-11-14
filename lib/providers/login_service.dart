import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:testproject/providers/shared_preferences_services.dart';

class UserLogin with ChangeNotifier {
  bool isLoggedIn = false;

  Future<bool> loginApi(String password, String email) async {
    final PrefService _prefs = PrefService();
    var response = await http.post(
      Uri.parse(
          'https://phplaravel-1005299-3647050.cloudwaysapps.com/api/v1/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      /*  Map<Todo, dynamic> data =
            new Map<Todo, dynamic>.from(json.decode(response.body));
        print(data.length); */
      Map<String, dynamic> datamap = await json.decode(response.body);
      if (datamap['ResultCode'] == 1500) {}


      String token = datamap['ResponseData']['authToken'];
      int storeid = datamap['ResponseData']['store_id'];
      String storename = datamap['ResponseData']['storename'];
      // String companyPhone = datamap['ResponseData']['CompanyPhone'].toString();
      print("$token $storeid  ");
      String logineduserName = datamap['ResponseData']['name'];
      _prefs.createCache(token, storeid.toString(), logineduserName, storename);

      // save user data to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': token,
        'name': datamap['ResponseData']['name'],
        'storeId': datamap['ResponseData']['store_id'],
        'storeName': datamap['ResponseData']['storename']
      });

      prefs.setString('userData', userData);
      // end
      isLoggedIn = true;
      notifyListeners();
      return isLoggedIn;
    } else {
      return isLoggedIn;
    }
  }
}
