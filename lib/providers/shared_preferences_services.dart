import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/models/authTokenStoreid.dart';

class PrefService extends ChangeNotifier {
  Future createCache(String token, String storeid, String loggedInUserName,
      String storename) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();

    _preferences.setString('Token', token);
    _preferences.setString('StoreId', storeid);
    _preferences.setString('loggedInUserName', loggedInUserName);
    _preferences.setString('storename', storename);
  }

  Future<Map<dynamic, dynamic>> readCache(String token, String storeid,
      String loggedInUserName, String storename) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();

    var cache = new Map();
    cache['Token'] = _preferences.getString('Token');
    cache['StoreId'] = _preferences.getString('StoreId');
    cache['loggedInUserName'] = _preferences.getString('loggedInUserName');
    cache['storename'] = _preferences.getString('storename');
    cache['companypPhone'] = _preferences.getString('companyPhone');

    return cache;
  }

  Future removeCache(String token, String storeid, String loggedInUserName,
      String storename) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();

    _preferences.remove('Token');
    _preferences.remove('StoreId');
    _preferences.remove('loggedInUserName');
    _preferences.remove('storename');
  }

  notifyListeners();
}
