import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:testproject/providers/shared_preferences_services.dart';

class UserLogin with ChangeNotifier {
  Future<bool> loginApi(String password, String email) async {
    List<dynamic> respData;
    final PrefService _prefs = PrefService();
    var response = await http.post(
      Uri.parse('https://apoyobackend.softcloudtech.co.ke/api/v1/login'),
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
      print(
          'ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd  dddddddddd userdat$datamap');
      String token = datamap['ResponseData']['authToken'];
      int storeid = 121;
      print(
          "store id ----------------------------------------------------------------------- $storeid");
      String logineduserName = datamap['ResponseData']['name'];
      _prefs.createCache(token, storeid.toString(), logineduserName);

      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
