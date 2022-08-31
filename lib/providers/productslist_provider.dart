import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:testproject/models/postSale.dart';

import 'package:testproject/models/product.dart';
import 'api_service.dart';

class ProductListProvider with ChangeNotifier {
  int _totalbill = 0;
  int _balance = 0;
  int _totalpayment = 0;
  List printers = [];
  var _accountSelected;
  List<Payment> _payments = [];
  List<SaleRow> _productList = [];

  List<SaleRow> get productlist {
    return [..._productList];
  }

  List<Payment> get paymentlist {
    return [..._payments];
  }

  dynamic get accountSelected {
    return accountSelected;
  }

  int get totabill => _totalbill;
  int get balance => _balance;
  int get totalpayment => _totalpayment;
  void addProduct(item) {
    _productList.add(item);
    notifyListeners();
  }

  int totalPrice() {
    _totalbill = 0;
    _productList.forEach((item) {
      //calculate the total prices
      _totalbill = _totalbill + item.lineTotal;
    });
    notifyListeners();
    return _totalbill;
  }

  void removeProduct(index) {
    if (balance == 0) {
      _totalbill = _totalbill - _productList[index].lineTotal;
      _productList.removeAt(index);
    }
    if (totalpayment == 0.0 && balance == 0.0) {
      _totalbill = _totalbill - _productList[index].lineTotal;
      _productList.removeAt(index);
    }
    if (totalpayment == 0.0 && balance == 0.0) {
      _totalbill = _totalbill - _productList[index].lineTotal;
      _productList.removeAt(index);
    }

    _totalbill = _totalbill - _productList[index].lineTotal;
    _productList.removeAt(index);
    notifyListeners();
  }

  void addPayment(payment) {
    _payments.add(payment);

    notifyListeners();
  }

  int totalPaymentcalc() {
    _totalpayment = 0;
    _payments.forEach((item) {
      _totalpayment += item.sumApplied!;
    });
    notifyListeners();
    return _totalpayment;
  }

  int balancepayment() {
    _balance = _totalbill - totalPaymentcalc();
    notifyListeners();
    return _balance;
  }

  void postsalearray(salecard) {
    GetProducts _salebody = GetProducts();
    print('PostSalearray Method Sale Card $salecard');
    _salebody.postsale(salecard);
  }

  void removePayment(index) {
    _totalpayment = _totalpayment - _payments[index].sumApplied!;
    _payments.removeAt(index);
    notifyListeners();
  }

  void setprodLIstempty() {
    _productList = [];
    _payments = [];
    notifyListeners();
  }

  void accountchoice(accountUserSelected) {
    _accountSelected = accountUserSelected;
    notifyListeners();
  }

  void addPrinter(addbluetoothPrinter) {
    printers.add(addbluetoothPrinter);
    notifyListeners();
  }
}
