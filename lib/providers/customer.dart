import 'dart:convert';

import '../utils/http.dart';
import 'package:flutter/foundation.dart';

class CustomerProvider with ChangeNotifier {
  List _customers = [];

  List get allCustomers {
    return [..._customers];
  }


  Future<List<dynamic>> fetchCustomers() async {
    try {
      final response = await httpGet('customers');
      final customers = jsonDecode(response.body);
      if(customers['ResponseData'] != null) {
        _customers = customers['ResponseData'];
      }

      notifyListeners();
      return _customers;
    } catch (error) {
      print('customer error $error');
      rethrow;
    }
  }
}
