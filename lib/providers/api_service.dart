import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testproject/databasesql/sql_database_connection.dart';
import 'package:testproject/databasesql/tables_schema.dart';

import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/customermode.dart';
import 'package:testproject/models/depositPayment.dart';

import 'package:testproject/models/paymentsAccounts.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/models/product.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/utils/http.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/constants.dart';

class GetProducts with ChangeNotifier {
  var data;
  var _soldProducts;
  var selectedprod;
  var accountsdata;
  var response;
  var _responseCode;
  var _totalsale;
  var _allStores;
  var _resultDes;
  int totalpayments = 0;
  bool _isloading = false;
  Map<String, dynamic> _generalSettingDetails = {};
  PrefService _prefs = PrefService();

  bool get isloading => _isloading;
  Map<String, dynamic> get generalSettingsDetails => _generalSettingDetails;

  get resultDesc => _resultDes;
  get responseCode => _responseCode;
  get soldProducrs => _soldProducts;
  get dailytotalsales => _totalsale;
  get allStores => _allStores;
  // Map<String, dynamic> get generalSettingDetails => _generalSettingDetails;
  var database;

  setislodaing() {
    _isloading = true;
    notifyListeners();
    return _isloading;
  }

  setislodaingfalse() {
    _isloading = false;
    notifyListeners();
    return _isloading;
  }

  //This function set the headers for api calls
  sethenders() async {
    var cache = await _prefs.readCache(
        'Token', 'StoreId', 'loggedinUserName', 'storename');

    String token = cache['Token'];
    String storeId = cache['StoreId'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };
    return headers;
  }

  Future<List<dynamic>> getProductsList(String? query) async {
    final queryparamaeters = jsonEncode({
      "searchText": "$query",
    });
    var headers = await sethenders();

    var url = Uri.parse('$backendUrl/search-products-mobile-api');
    try {
      if (query != null) {
        response =
            await http.post(url, headers: headers, body: queryparamaeters);
        if (response.statusCode == 200) {
          print('Sucessful POst');
          data = jsonDecode(response.body)['ResponseData'];
          print("Wwrknknfkwnkfnwkenfkwenkgfnekmgfekmgf");
          return data;
        }
      } else {
        /* final queryparamaeters = jsonEncode({
          "searchText": "",
        });
        try {
          response =
              await http.post(url, headers: headers, body: queryparamaeters);
        } catch (e) {
          print("Error occured when body is empty string $e");
        } */
      }

      if (response.statusCode == 200) {
        /* print('Sucessful POst');
        data = jsonDecode(response.body)['ResponseData'];

        //print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${data['ResponseData']}");
        /*  data = json.decode(response.body);
        print(data); */
        //result = data.map((e) => ResponseData.fromJson(e)).toList();
        /* ata = data.map((e) => ResponseDatum.fromJson(e)).toList();
        print(
            '########################################################## $data}['
            ']');
        data.foreach((e) => print(e)); */

        return data; */
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } on Exception catch (e) {
      print(e);
    }

    return data = [];
  }

  // Future<List<dynamic>> getaccounts(String? searchquery) async {
  //   var headers = await sethenders();
  //   var accountsdata;
  //   final queryparamaeters = jsonEncode({
  //     "searchText": "$searchquery",
  //   });
  //
  //   var url = Uri.https(baseUrl, '/api/v1/bank-accounts');
  //
  //   response = await http.get(url, headers: headers);
  //   accountsdata = jsonDecode(response.body)['ResponseData'];
  //   notifyListeners();
  //
  //   return accountsdata;
  // }



  postsale(salecard) async {
    var headers = await sethenders();
    final queryparamaeters = posSaleToJson(salecard);

    print(jsonDecode(queryparamaeters));

    try {
      // post salecard to sqlite
      response = await httpPost('create-document', queryparamaeters);
      data = await jsonDecode(response.body);

      notifyListeners();
      return data;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  void getBankAccounts() async {
    var headers = await sethenders();
    var url = Uri.https(baseUrl, '/api/v1/bank-accounts');
    response = await http.get(
      url,
      headers: headers,
    );
  }

  void selectedProduct(productSelected) {
    selectedprod = productSelected;
    //print(selectedprod);
  }

  Future<List<dynamic>> fetchSoldProducts(startDate) async {
    var headers = await sethenders();
    final queryparameters = jsonEncode({
      "StartDate": startDate,
      "combinedReport": "N",
      "SoldBy": null,
      "CustomerID": null,
      "ProductID": null
    });
    var url = Uri.https(baseUrl, '/api/v1/bought-sold-products/14');
    response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    if (response.statusCode == 200) {
      print('Customer Fetch ');
    }
    data = await jsonDecode(response.body)['ResponseData']['AllProductsSold'];
    _soldProducts = data;
    notifyListeners();
    return data;
  }



//Fetching payment data
  Future<List<dynamic>> fetchSalePayments(startDate) async {
    var headers = await sethenders();
    print('Start Date $startDate');
    var queryparameters = jsonEncode({
      "storeid": "${headers['storeid']}",
      "StartDate": "$startDate",
      "EndDate": "$startDate",
    });

    try {
      print('Params Fect Payments $queryparameters');
      var url = Uri.https(baseUrl, '/api/v1/sale-payments-report');
      print(url);
    } catch (e) {
      print(e);
    }
    var url = Uri.https(baseUrl, '/api/v1/sale-payments-report');
    response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    print('Response ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Customer Fetch ');
      data = await jsonDecode(response.body)['ResponseData']['AllPayments'];
    }
    notifyListeners();
    return data;
  }

  Future defaultPrinterAddress(printerAddress) async {
    var headers = await sethenders();

    final queryparameters = jsonEncode({
      "store_id": headers['storeid'],
      'address': printerAddress,
    });

    var url = Uri.https(baseUrl, '/api/v1/store-mac-address');
    response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Customer Fetch ');
    }
    data = await jsonDecode(response.body);
    print(data);

    notifyListeners();
    return data;
  }

  /* Future<List<dynamic>> getPrinterAddress() async {
    var headers = await sethenders();
    var url = Uri.https(baseUrl,
        '/api/v1/store-mac-address/${headers['storeid']}');
    response = await http.get(
      url,
      headers: headers,
    );
    data = await jsonDecode(response.body);

    print(
        'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr${data}');
    return data['ResponseData'];
  } */

  Future<int> getTotalPayments(query) async {
    var data;
    var headers = await sethenders();
    final queryparameters = jsonEncode({
      "storeid": "${headers['storeid']}",
      "StartDate": "$query",
      "EndDate": "$query",
    });

    var url = Uri.https(baseUrl, '/api/v1/sale-payments-report');
    var response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    if (response.statusCode == 200) {
      data = await jsonDecode(response.body)['ResponseData']['TotalAmount'];
      /* TotalAmountData totalpaymentdata =
          data.map((dynamic item) => TotalAmountData.fromJson(item)).toList(); */
      totalpayments = data;

      notifyListeners();
      return data;
    } else {
      throw 'Cant get total payment';
    }
  }

  Future<int> getsoldtotals(_searchquery) async {
    var headers = await sethenders();
    final queryparameters = jsonEncode({
      "StartDate": _searchquery,
      "combinedReport": "N",
      "SoldBy": null,
      "CustomerID": null,
      "ProductID": null
    });
    var url = Uri.https(baseUrl, '/api/v1/bought-sold-products/14');
    var response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    if (response.statusCode == 200) {}
    var data =
        await jsonDecode(response.body)['ResponseData']['TotalSalesAmount'];

    _totalsale = data;

    return data;
  }

  //Credit memo
  void postCreditMemo(creditMemo) async {
    var headers = await sethenders();
    final queryparamaeters = creditMemoToJson(creditMemo);

    //print(jsonDecode(queryparamaeters));
    var url = Uri.https(
      baseUrl,
      '/api/v1/credit-memo',
    );
    try {
      response = await http.post(
        url,
        headers: headers,
        body: queryparamaeters,
      );
      print('Query paramsaleCardaeters $queryparamaeters');

      print('response from postr sale ${response.body}');
    } catch (e) {
      print(e);
    }
  }

// Fetching returned Products
  Future<List<dynamic>> fetchReturnedProducts(startDate) async {
    var headers = await sethenders();
    print('Start Date $startDate');
    var queryparameters = jsonEncode({
      "storeid": "${headers['storeid']}",
      "StartDate": "$startDate",
      "EndDate": "$startDate",
    });

    try {
      print('Params Fetch retruned Products $queryparameters');
      var url = Uri.https(baseUrl, '/api/v1/returned-products-report');
      print(url);
    } catch (e) {
      print(e);
    }
    var url = Uri.https(baseUrl, '/api/v1/returned-products-report');
    response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    print('Response ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Customer Fetch ');
      data = await jsonDecode(response.body)['ResponseData']['AllSales'];
    }
    notifyListeners();
    return data;
  }

  void postDepositSale(salecard) async {
    print('Print Sales $salecard');
    var headers = await sethenders();
    final queryparamaeters = posSaleToJson(salecard);

    //print(jsonDecode(queryparamaeters));
    var url = Uri.https(
      baseUrl,
      '/api/v1/sale-deposit',
    );
    try {
      response = await http.post(
        url,
        headers: headers,
        body: queryparamaeters,
      );
      print('Query param Deposit sale Card $queryparamaeters');

      print('response from Deposit Sale ${response.body}');
    } catch (e) {
      print(e);
    }
  }

  Future<List<dynamic>> fetchDeposits() async {
    var headers = await sethenders();

    var url = Uri.https(baseUrl, '/api/v1/deposits-list');
    response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200) {
      print('Customer Fetch ');
    }
    data = await jsonDecode(response.body)['ResponseData'];
    print('data fetch deposits $data');
    notifyListeners();
    return data;
  }

  void postDepositPayment(depositPayment) async {
    print('Print Sales $depositPayment');
    var headers = await sethenders();
    final queryparamaeters = depositPaymentToJson(depositPayment);

    //print(jsonDecode(queryparamaeters));
    var url = Uri.https(
      baseUrl,
      '/api/v1/deposit-payment',
    );
    try {
      response = await http.post(
        url,
        headers: headers,
        body: queryparamaeters,
      );
      //print('Query param Deposit sale Card $queryparamaeters');

      //print('response from Deposit Sale ${response.body}');
    } catch (e) {
      print(e);
    }
  }

  void fetchshopDetails() async {
    var headers = await sethenders();

    var url = Uri.https(baseUrl, '/api/v1/general-settings');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('Sucessful POst');
    }
    _generalSettingDetails = jsonDecode(response.body)['ResponseData'];
    notifyListeners();
    print("General Setting Data $_generalSettingDetails ");
  }

  /*  Future<Map<String, dynamic>> fetchPriceList(productId, o_p_l_n_s_id) async {
    var headers = await sethenders();
    final queryparameters = jsonEncode({
      "product_id": productId,
      "store_id": headers['storeid'],
      "o_p_l_n_s_id": o_p_l_n_s_id
    });
    var url = Uri.https(
        baseUrl, '/api/v1/price-calculation');
    response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    if (response.statusCode == 200) {
      print('Customer Fetch ');
    }
    data = await jsonDecode(response.body)['ResponseData'];
    print('fecth PriceList $data');
    notifyListeners();
    return data;
  }
}
 */

  void fetchallStores() async {
    var headers = await sethenders();

    var url = Uri.https(baseUrl, '/api/v1/all/stores');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {}
    _allStores = jsonDecode(response.body)['ResponseData'];
    notifyListeners();
    print("all stores $_allStores");
  }
}
