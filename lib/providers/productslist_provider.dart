import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:testproject/models/creditmemo.dart';

import 'package:testproject/models/postSale.dart';

import 'api_service.dart';

class ProductListProvider with ChangeNotifier {
  double _discount = 0;
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
  String _customerName = '';
  String _customerPhone = '';
  String _saleDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  List<SaleRow> _depositProductsList = [];
  List<TopupPayment> _topUpPaymentList = [];
  List<ReplacedProduct> _replacementProductList = [];
  List<ReturnedProduct> _returnProductList = [];
  List<Payment> _payments = [];
  List<SaleRow> _productList = [];
  List<Payment> _depositPaymentsList = [];
  dynamic _depositItem;
  String _selecteddate = '';
  bool _multiplePriceList = false;
  List<SaleRow> get productlist {
    return [..._productList];
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

  double get discount => _discount;
  double get totabill => _totalbill;
  double get totaDepositBill => _totalDepositBill;
  double get billBalance => _balance;
  double get depositBalance => _depositBalance;
  double get totalpayment => _totalpayment;
  String get previousRoute => _previousRoute;
  String get customerName => _customerName;
  String get dateSetSale => _saleDate;
  String get customerPhone => _customerPhone;
  dynamic get selecteddepositItem => _depositItem;
  String get selectedDate => _selecteddate;
  double get totalDepositPayment => _totalDepositPayments;
  bool get multiplePriceList => _multiplePriceList;

  /* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  
              CREDT MEMO 
  
  
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   */
  List<ReplacedProduct> get replacementProductList {
    return [..._replacementProductList];
  }

  List<ReturnedProduct> get returnProductList {
    return [..._returnProductList];
  }

  List<TopupPayment> get topUpPaymentList {
    return [..._topUpPaymentList];
  }

  int get totalReturnPayment => _totalReturnPayment;
  double get totalReplacementCost => _totalReplacementCost;
  double get topUpBalance => _topUpBalance;

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

  void addDiscount(discount) {
    _discount = discount;
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

/* 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

              NEW SALE FUNCTIONS 




^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  */
//Add products new sale funttions
  void addProduct(item) {
    _productList.add(item);
    notifyListeners();
  }

  void resetsetdiscount() {
    _discount = 0;
    _balance = 0;
  }

  double totalPrice() {
    _totalbill = 0;
    _productList.forEach((item) {
      //calculate the total prices
      _totalbill = _totalbill + item.lineTotal;
    });
    return _totalbill - _discount;
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
    //notifyListeners();
    return _totalpayment;
  }

  void removeProduct(index) {
    // if (billBalance == 0) {
    //   _totalbill = _totalbill - _productList[index].lineTotal - _discount;
    //   _productList.removeAt(index);
    // }
    // if (totalpayment == 0.0 && billBalance == 0.0) {
    //   _totalbill = _totalbill - _productList[index].lineTotal - _discount;
    //   _productList.removeAt(index);
    // }
    // if (totalpayment == 0.0 && billBalance == 0.0) {
    //   _totalbill = _totalbill - _productList[index].lineTotal - _discount;
    //   _productList.removeAt(index);
    // }
    _totalbill = _totalbill - _productList[index].lineTotal - _discount;
    _productList.removeAt(index);
    balancepayment();
    notifyListeners();
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

  void postsalearray(salecard) {
    GetProducts _salebody = GetProducts();
    _salebody.postsale(salecard);
  }

  /*  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


                  GAS SALE FUNCTIONS 



^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*/

  List<SaleRow> _gasProductList = [];
  double _totalGasBill = 0;
  List<Payment> _gasPaymentsList = [];
  double billGasBalance = 0;
  double _totalGasPayment = 0;
  double _gasBalance = 0;
  double _gasPrice = 0;

  List<SaleRow> get gasProductList => _gasProductList;
  double get totalGasBill => _totalGasBill;

  List<Payment> get gasPaymentsList {
    return [..._gasPaymentsList];
  }

  List<Payment> get gasPaymentList {
    return [..._gasPaymentsList];
  }

  double get totalGasPayment => _totalGasPayment;
  double get gasBalance => _gasBalance;
  double get selectedGasPrice => _gasPrice;

  setselectededGasPrice(gasPrice) {
    _gasPrice = gasPrice;
    notifyListeners();
    return _gasPrice;
  }

  resetsetselectededGasPrice() {
    _gasPrice = 0;
    notifyListeners();
    return _gasPrice;
  }

  void addGasProduct(item) {
    _gasProductList.add(item);
    notifyListeners();
  }

  double totalGasPrice() {
    _totalGasBill = 0;
    _gasProductList.forEach((item) {
      //calculate the total prices
      _totalGasBill = _totalGasBill + item.lineTotal;
    });
    notifyListeners();
    return _totalGasBill;
  }

  void addGasPayment(payment) {
    _gasPaymentsList.add(payment);

    notifyListeners();
  }

  void removeGasProduct(index) {
    if (billGasBalance == 0) {
      _totalGasBill = _totalGasBill - _gasProductList[index].lineTotal;
      _gasProductList.removeAt(index);
      notifyListeners();
    } else if (_totalGasPayment == 0.0 && billGasBalance == 0.0) {
      _totalGasBill = _totalGasBill - _gasProductList[index].lineTotal;
      _gasProductList.removeAt(index);
      notifyListeners();
    } else if (_totalGasPayment == 0.0 && billGasBalance == 0.0) {
      _totalGasBill = _totalGasBill - _gasProductList[index].lineTotal;
      _gasProductList.removeAt(index);
      notifyListeners();
    } else {
      _totalGasBill = _totalGasBill - _gasProductList[index].lineTotal;
      _gasProductList.removeAt(index);
      notifyListeners();
    }
  }

  void removeGasPayment(index) {
    _totalGasPayment = _totalGasPayment - _gasPaymentsList[index].sumApplied!;
    _gasPaymentsList.removeAt(index);
    notifyListeners();
  }

  void setGasProdListEmpty() {
    _gasProductList = [];
    _gasPaymentsList = [];
    notifyListeners();
  }

  void postGasSale(salecard) {
    GetProducts _salebody = GetProducts();
    _salebody.postsale(salecard);
  }

  double totalGasPaymentcalc() {
    _totalGasPayment = 0;
    _gasPaymentsList.forEach((item) {
      _totalGasPayment += item.sumApplied!;
    });
    notifyListeners();
    return _totalGasPayment;
  }

  double balanceGasPayment() {
    _gasBalance = 0;
    _gasBalance = _totalGasBill - totalGasPaymentcalc();
    notifyListeners();
    return _gasBalance;
  }

  void resetGasCustmerPhone() {
    _customerPhone = '';
    notifyListeners();
  }
  /* 
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  


                    DEPOSIT FUNCTIONS




  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  */

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
    return _balance - _discount;
  }

  double depositbalance() {
    _depositBalance = _totalDepositBill - totalDepositPaymentcalc();
    notifyListeners();
    return _depositBalance;
  }

  void postDepositarray(salecard) {
    GetProducts _salebody = GetProducts();

    // CHane to post deposit
    _salebody.postsale(salecard);
  }

/* 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


                    GENERAL SETTINGS FUNCTIONS


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  */
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

    notifyListeners();
    return _customerPhone;
  }

  void resetCustmerPhone() {
    _customerPhone = '';
    notifyListeners();
  }

  void resetCustomerName() {
    _customerName = ' ';
    notifyListeners();
  }

  void setSaleDate(saleDate) {
    _saleDate = saleDate;
    notifyListeners();
  }

  void selectedDepositItem(depositItem) {
    _depositItem = depositItem;
    notifyListeners();
  }

  void setselectedDate(selectedDateString) {
    _selecteddate = selectedDateString;
  }

  void resetSelectedDate() {
    _selecteddate = '';
  }

  void setMultiplePriceList(value) {
    _multiplePriceList = value;
  }

  /* 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Transfer Products 



^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*****************************/
}
