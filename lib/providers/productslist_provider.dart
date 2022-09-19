import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:testproject/models/creditmemo.dart';

import 'package:testproject/models/postSale.dart';

import 'api_service.dart';

class ProductListProvider with ChangeNotifier {
  double _totalbill = 0;
  double _totalDepositBill = 0;
  double _balance = 0;
  double _depositBalance = 0;
  double _totalpayment = 0;
  List printers = [];
  var _accountSelected;
  double _totalDepositPayments = 0;
  String _previousRoute = '';
  int _totalReturnPayment = 0;
  double _returnTotalCost = 0;
  double _totalReplacementCost = 0;
  double _topUpBalance = 0;
  int _totalTopUpPayment = 0;
  String _customerName = ' ';
  String _customerPhone = " ";
  String _saleDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  List<SaleRow> _depositProductsList = [];
  List<TopupPayment> _topUpPaymentList = [];
  List<ReplacedProduct> _replacementProductList = [];
  List<ReturnedProduct> _returnProductList = [];
  List<Payment> _payments = [];
  List<SaleRow> _productList = [];
  List<Payment> _depositPaymentsList = [];
  dynamic _depositItem;

  List<SaleRow> get productlist {
    return [..._productList];
  }

  List<ReplacedProduct> get replacementProductList {
    return [..._replacementProductList];
  }

  List<ReturnedProduct> get returnProductList {
    return [..._returnProductList];
  }

  List<TopupPayment> get topUpPaymentList {
    return [..._topUpPaymentList];
  }

  List<Payment> get depositPaymentList {
    return [..._depositPaymentsList];
  }

  List<SaleRow> get depositProductsList {
    return [..._depositProductsList];
  }

  List<Payment> get paymentlist {
    return [..._payments];
  }

  dynamic get accountSelected {
    return _accountSelected;
  }

  double get totabill => _totalbill;
  double get totaDepositBill => _totalDepositBill;
  int get totalReturnPayment => _totalReturnPayment;
  double get billBalance => _balance;
  double get depositBalance => _depositBalance;
  double get totalpayment => _totalpayment;
  double get totalReplacementCost => _totalReplacementCost;
  double get topUpBalance => _topUpBalance;
  String get previousRoute => _previousRoute;
  String get customerName => _customerName;
  String get dateSetSale => _saleDate;
  String get customerPhone => _customerPhone;
  dynamic get selecteddepositItem => _depositItem;
//Replacement Product functions

  void setCreditNoteListempty() {
    _replacementProductList = [];
    _returnProductList = [];
    _topUpPaymentList = [];
    _topUpBalance = 0;
    notifyListeners();
  }

  void setTopUpPaymentListEmpty() {
    _topUpPaymentList = [];
    notifyListeners();
  }

  void addReplacementProduct(item) {
    _replacementProductList.add(item);
    notifyListeners();
  }

  double totalReplacementPrice() {
    _totalReplacementCost = 0;
    _replacementProductList.forEach((item) {
      //calculate the total prices
      _totalReplacementCost = _totalReplacementCost + item.lineTotal;
    });
    notifyListeners();
    return _totalReplacementCost;
  }

  void removeReplacementProduct(index) {
    _totalReplacementCost =
        _totalReplacementCost - _replacementProductList[index].lineTotal;
    _replacementProductList.removeAt(index);
    notifyListeners();
  }

  double topUpBalanceCalc() {
    _topUpBalance =
        (_totalReplacementCost - _returnTotalCost) - _totalTopUpPayment;
    notifyListeners();
    return _topUpBalance;
  }

  void addTopUpPayment(topUpPayment) {
    _topUpPaymentList.add(topUpPayment);
  }

  void removeTopUpPayment(index) {
    _totalTopUpPayment =
        _totalTopUpPayment - _topUpPaymentList[index].SumApplied!;
    _topUpPaymentList.removeAt(index);
    notifyListeners();
  }

  int totalTopUpPaymentcalc() {
    _totalTopUpPayment = 0;
    _topUpPaymentList.forEach((item) {
      _totalTopUpPayment += item.SumApplied!;
    });
    notifyListeners();
    return _totalTopUpPayment;
  }

//Retrun Products Functions
  void addReturnProduct(item) {
    _returnProductList.add(item);
    notifyListeners();
  }

  void removeReturnProduct(index) {
    _returnTotalCost = _returnTotalCost - _returnProductList[index].lineTotal;
    _returnProductList.removeAt(index);
    notifyListeners();
  }

  double totalRetrunPrice() {
    _returnTotalCost = 0;
    _returnProductList.forEach((item) {
      //calculate the total prices
      _returnTotalCost = _returnTotalCost + item.lineTotal;
    });
    notifyListeners();
    return _returnTotalCost;
  }

//Add products new sale funttions
  void addProduct(item) {
    _productList.add(item);
    notifyListeners();
  }

  double totalPrice() {
    _totalbill = 0;
    _productList.forEach((item) {
      //calculate the total prices
      _totalbill = _totalbill + item.lineTotal;
    });
    notifyListeners();
    return _totalbill;
  }

  void addPayment(payment) {
    _payments.add(payment);

    notifyListeners();
  }

  double totalPaymentcalc() {
    _totalpayment = 0;
    _payments.forEach((item) {
      _totalpayment += item.sumApplied!;
    });
    notifyListeners();
    return _totalpayment;
  }

  void removeProduct(index) {
    if (billBalance == 0) {
      _totalbill = _totalbill - _productList[index].lineTotal;
      _productList.removeAt(index);
    }
    if (totalpayment == 0.0 && billBalance == 0.0) {
      _totalbill = _totalbill - _productList[index].lineTotal;
      _productList.removeAt(index);
    }
    if (totalpayment == 0.0 && billBalance == 0.0) {
      _totalbill = _totalbill - _productList[index].lineTotal;
      _productList.removeAt(index);
    }

    _totalbill = _totalbill - _productList[index].lineTotal;
    _productList.removeAt(index);
    notifyListeners();
  }

// Deposit funttions
  double totalDepositPrice() {
    _totalDepositBill = 0;
    _depositProductsList.forEach((item) {
      //calculate the total prices
      _totalDepositBill = _totalDepositBill + item.lineTotal;
    });
    notifyListeners();
    return _totalDepositBill;
  }

  void addDepositProduct(item) {
    _depositProductsList.add(item);
    notifyListeners();
  }

  void removeDepositProduct(index) {
    _totalDepositBill =
        _totalDepositBill - _depositProductsList[index].lineTotal;
    _depositProductsList.removeAt(index);
    notifyListeners();
  }

  void addDepositPayment(depositPayment) {
    _depositPaymentsList.add(depositPayment);
  }

  void removeDepositPayment(index) {
    _totalDepositPayments =
        _totalDepositPayments - _depositPaymentsList[index].sumApplied!;
    _depositPaymentsList.removeAt(index);
    notifyListeners();
  }

  double totalDepositPaymentcalc() {
    _totalDepositPayments = 0;
    _depositPaymentsList.forEach((item) {
      _totalDepositPayments += item.sumApplied!;
    });
    notifyListeners();
    return _totalDepositPayments;
  }

  void setDepositListempty() {
    _depositProductsList = [];
    _depositPaymentsList = [];
    notifyListeners();
  }

  double balancepayment() {
    _balance = 0;
    _balance = _totalbill - totalPaymentcalc();
    notifyListeners();
    return _balance;
  }

  double depositbalance() {
    _depositBalance = _totalDepositBill - totalDepositPaymentcalc();
    notifyListeners();
    return _depositBalance;
  }

  void postsalearray(salecard) {
    GetProducts _salebody = GetProducts();
    print('PostSalearray Method Sale Card $salecard');
    _salebody.postsale(salecard);
  }

  void postDepositarray(salecard) {
    GetProducts _salebody = GetProducts();
    print('PostSalearray Method Sale Card $salecard');

    // CHane to post deposit
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

  accountchoice(accountUserSelected) {
    _accountSelected = accountUserSelected;
    notifyListeners();
    return _accountSelected;
  }

  void addPrinter(addbluetoothPrinter) {
    printers.add(addbluetoothPrinter);
    notifyListeners();
  }

  void setPreviousRoute(routeString) {
    _previousRoute = routeString;
    notifyListeners();
  }

  void setCustomerName(customerName) {
    _customerName = customerName;
    notifyListeners();
  }

  setCustomerPhone(customerno) {
    _customerPhone = customerno;
    return _customerPhone;
  }

  resetCustmerPhone() {
    _customerPhone = '';

    return _customerPhone;
  }

  resetCustomerName() {
    _customerName = '';
    return _customerName;
  }

  void setSaleDate(saleDate) {
    _saleDate = saleDate;
    notifyListeners();
  }

  void selectedDepositItem(depositItem) {
    _depositItem = depositItem;
    notifyListeners();
  }
}
