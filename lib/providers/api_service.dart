import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testproject/models/accountmodel.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/customermode.dart';
import 'package:testproject/models/login_requestmodel.dart';
import 'package:testproject/models/macaddress.dart';
import 'package:testproject/models/paidamount.dart';
import 'package:testproject/models/paymentsAccounts.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/models/product.dart';
import 'package:testproject/providers/shared_preferences_services.dart';

class GetProducts with ChangeNotifier {
  var data;
  var selectedprod;
  var accountsdata;
  var response;
  int totalpayments = 0;
  bool _isloading = false;

  PrefService _prefs = PrefService();

  List<ResponseDatum> result = [];
  bool get isloading => _isloading;

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

  Future<List<dynamic>> getTodoList(String? query) async {
    final queryparamaeters = jsonEncode({
      "searchText": "$query",
    });
    var headers = await sethenders();

    var url = Uri.https('apoyobackend.softcloudtech.co.ke',
        '/api/v1/search-products-mobile-api');

    try {
      if (query != null) {
        response =
            await http.post(url, headers: headers, body: queryparamaeters);
        if (response.statusCode == 200) {
          print('Sucessful POst');
          data = jsonDecode(response.body)['ResponseData'];

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
    } on Exception catch (e) {}

    return data = [];
  }

  Future<List<dynamic>> getaccounts(searchquery) async {
    var headers = await sethenders();
    List<dynamic> accountsdata;
    final queryparamaeters = jsonEncode({
      "searchText": "$searchquery",
    });

    var url =
        Uri.https('apoyobackend.softcloudtech.co.ke', '/api/v1/bank-accounts');

    /* if (searchquery != null) {
      response = await http.post(url, headers: headers, body: queryparamaeters);
      if (response.statusCode == 200) {
        print('Sucessful POst');
        accountsdata = jsonDecode(response.body)['ResponseData'];
        return accountsdata;
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } */
    response = await http.get(url, headers: headers);
    accountsdata = jsonDecode(response.body)['ResponseData'];
    notifyListeners();

    return accountsdata;
  }

  Future<List<CustomersResponseDatum>> getcustomers(
      String? querycustomerName) async {
    var headers = await sethenders();
    final queryparamaeters = jsonEncode({
      "searchText": "$querycustomerName",
    });
    List<CustomersResponseDatum> customersdata;

    var url = Uri.https('apoyobackend.softcloudtech.co.ke', '/customers');
    response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('Customer Fetch ');
    }
    customersdata = await jsonDecode(response.body)['ResponseData'];

    notifyListeners();
    return customersdata;
    /* customersdata
        .map((json) => CustomersResponseDatum.fromJson(json))
        .where((customerdata) {_linenum
                            prodproducts_linenum
      final customerName = customerdata.name.toLowerCase();
      final querycustomerLower = querycustomerName!.toLowerCase();
      return customerName.contains(querycustomerLower);
    }).toList();*/
  }

  postsale(salecard) async {
    print('Print Sales $salecard');
    var headers = await sethenders();
    final queryparamaeters = posSaleToJson(salecard);

    //print(jsonDecode(queryparamaeters));
    var url = Uri.https(
      'apoyobackend.softcloudtech.co.ke',
      '/api/v1/documents',
    );
    try {
      response = await http.post(
        url,
        headers: headers,
        body: queryparamaeters,
      );

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  void getBankAccounts() async {
    var headers = await sethenders();
    var url =
        Uri.https('apoyobackend.softcloudtech.co.ke', '/api/v1/bank-accounts');
    response = await http.get(
      url,
      headers: headers,
    );
  }

  void selectedProduct(ResponseDatum productSelected) {
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
    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/bought-sold-products/14');
    response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    if (response.statusCode == 200) {
      print('Customer Fetch ');
    }
    data = await jsonDecode(response.body)['ResponseData']['AllProductsSold'];

    notifyListeners();
    return data;
  }

  Future<PaymentAccountsResponseData> getanaccount(accountId) async {
    var headers = await sethenders();
    PaymentAccountsResponseData accountsdata;

    var url =
        Uri.https('apoyobackend.softcloudtech.co.ke', '/api/v1/bank-accounts');
    response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('Sucessful POst');
    }
    accountsdata = jsonDecode(response.body)['ResponseData'];

    notifyListeners();
    return accountsdata;
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
      var url = Uri.https(
          'apoyobackend.softcloudtech.co.ke', '/api/v1/sale-payments-report');
      print(url);
    } catch (e) {
      print(e);
    }
    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/sale-payments-report');
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

  Future<String> defaultPrinterAddress(printerAddress) async {
    var headers = await sethenders();
    print(printerAddress);
    print(headers['storeid']);
    final queryparameters = jsonEncode({
      "store_id": headers['storeid'],
      'address': printerAddress,
    });

    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/store-mac-address');
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
    var url = Uri.https('apoyobackend.softcloudtech.co.ke',
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

    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/sale-payments-report');
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
    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/bought-sold-products/14');
    var response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    if (response.statusCode == 200) {}
    var data =
        await jsonDecode(response.body)['ResponseData']['TotalSalesAmount'];

    return data;
  }

  //Credit memo
  void postCreditMemo(creditMemo) async {
    var headers = await sethenders();
    final queryparamaeters = creditMemoToJson(creditMemo);

    //print(jsonDecode(queryparamaeters));
    var url = Uri.https(
      'apoyobackend.softcloudtech.co.ke',
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
      var url = Uri.https('apoyobackend.softcloudtech.co.ke',
          '/api/v1/returned-products-report');
      print(url);
    } catch (e) {
      print(e);
    }
    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/returned-products-report');
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
      'apoyobackend.softcloudtech.co.ke',
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
}
