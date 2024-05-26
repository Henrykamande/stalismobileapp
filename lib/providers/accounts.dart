import 'dart:convert';

import '../utils/http.dart';
import 'package:flutter/foundation.dart';

class AccountsProvider with ChangeNotifier {
  List _accounts = [];

  List get allAccounts {
    return [..._accounts];
  }


  Future<List<dynamic>> fetchAccounts() async {
    try {
      final response = await httpGet('bank-accounts');
      final accounts = jsonDecode(response.body);
      if(accounts['ResponseData'] != null) {
        _accounts = accounts['ResponseData'];
      }

      notifyListeners();

      return _accounts;
    } catch (error) {
      print('accounts error $error');
      rethrow;
    }
  }
}
