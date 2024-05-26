import 'dart:convert';

import 'package:testproject/utils/shared_data.dart';

import '../utils/http.dart';
import 'package:flutter/foundation.dart';

class ProductsProvider with ChangeNotifier {
  List _products = [];

  List get allProducts {
    return [..._products];
  }

  Future<List<dynamic>> fetchProducts() async {
    try {
      var prefsData = await sharedData();
      var subscriberId = prefsData['subscriberId'];
      var storeId = prefsData['storeId'];

      final response = await httpGet('products-sync-mobile/$subscriberId/$storeId');
      final products = jsonDecode(response.body);
      if(products['ResponseData'] != null) {
        _products = products['ResponseData'];
      }

      notifyListeners();

      return _products;
    } catch (error) {
      print('products error $error');
      rethrow;
    }
  }
}
