import 'dart:convert';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testproject/constants/constants.dart';
import 'package:testproject/databasesql/sqldatabaseconnection.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/pages/printerPages/printerPage.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:intl/intl.dart';
import 'package:testproject/shared/drawerscreen.dart';

import 'package:http/http.dart' as http;
import 'package:testproject/utils/custom_select_box.dart';
import 'package:testproject/utils/http.dart';
import 'package:testproject/utils/saleValidation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PrefService _prefs = PrefService();
  final _formKey = GlobalKey<FormState>();
  var cache;
  bool _connected = false;
  Map<String, dynamic> _generalSettingDetails = {};
  String printerErrorMessage = "";
  TextEditingController dateInput = TextEditingController();
  String saleType = '';
  bool setdate = true;
  String storename = '';
  List<SaleRow> products = [];
  String customerNo = "";
  List alldrivers = [];
  var allCustomers;
  var selectedCustomerId = "";
  var selectedDriver = '';
  PrinterBluetooth? defaultPrinter;
  var selectedSaleType = '';
  var pickedBy = "";
  var _isLoading = false;
  var _selectedCustomer = {};
  final FocusNode _customerNameFocusNode = FocusNode();
  var customerSearchController = TextEditingController();
  List<dynamic> _customers = [];
  var _customerFocusNodes = <FocusNode>[];
  final FocusNode _customerSearchFocusNode = FocusNode();
  int _currentIndex = -1;

  String todayDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  final paymentTextStyle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54);

  var discountGiven = 0;
  var macaddress = '';
  List allSaleTypes = [];
  // var dateFormat = DateFormat("yyyy-MM-dd");
  // String todayDate = dateFormat.format(DateTime.now());

  TextEditingController dateController = TextEditingController();
  final formatnum = new NumberFormat("#,##0.00", "en_US");
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  @override
  void initState() {
    super.initState();
    fetchDrivers();
    fetchallSaleTypes();
    fetchCustomers();
    sethenders();
    setdate = true;
    //_getPrinterAddress();
    _scanPrinters();

    context.read<GetProducts>().fetchshopDetails();
    _generalSettingDetails = context.read<GetProducts>().generalSettingsDetails;
  }

  // select customer method
  void _selectCustomer(item) {
    setState(() {
      customerSearchController.text = '';
      _selectedCustomer = item;
      selectedCustomerId = item['id'].toString();
      _customers = [];
    });
  }
  // end

  // search customers method
  void _searchCustomers() async {
    final searchQuery = customerSearchController.text;
    _customerFocusNodes = [];

    if (searchQuery != '') {
      var params = {
        'searchText': searchQuery,
      };

      var headers = await sethenders();
      var url =
      Uri.https(baseUrl, '/api/v1/search-customer');
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(params),
      );

      var customerResults = jsonDecode(response.body);


      print(customerResults);
      List<dynamic> items = customerResults['ResponseData'];

      if (searchQuery != '') {
        setState(() {
          _customers = items;

          for (var node in _customerFocusNodes) {
            node.unfocus();
          }
          // end
          _customerFocusNodes
              .addAll(List.generate(items.length, (index) => FocusNode()));
        });
      }

      if (searchQuery == '') {
        setState(() {
          _customers = [];
        });
      }
    } else {
      setState(() {
        customerSearchController.text = '';
        _customers = [];
        // _currentIndex = -1;
      });
    }
  }
  // end


  void _scanPrinters() {
    printerManager.scanResults.listen((devices) async {
      // print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });

    _startScanDevices();
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  void fetchshopDetails() async {
    var headers = await sethenders();

    var url = Uri.https(baseUrl, '/api/v1/general-settings');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {}
    _generalSettingDetails = jsonDecode(response.body)['ResponseData'];
  }

  void fetchDrivers() async {
    final response = await httpGet('drivers');
    final driversResponse = jsonDecode(response.body);

    if (driversResponse['ResultCode'] == 1200) {
      setState(() {
        alldrivers = driversResponse['ResponseData'];
      });
    }
  }

  void fetchCustomers() async {
    allCustomers = await DatabaseHelper.instance.getAllCustomers();

    setState(() {
      allCustomers = allCustomers!;
    });
  }

  void fetchallSaleTypes() async {
    final response = await httpGet('sale-types');
    final driversResponse = jsonDecode(response.body);

    if (driversResponse['ResultCode'] == 1200) {
      setState(() {
        allSaleTypes = driversResponse['ResponseData'];
      });
    }
  }

  sethenders() async {
    cache = await _prefs.readCache(
        'Token', 'StoreId', 'loggedinUserName', 'storename');

    String token = cache['Token'];
    String storeId = cache['StoreId'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };
    setState(() {
      storename = cache['storename'];
    });
    return headers;
  }

  // _getPrinterAddress() async {
  //   var headers = await sethenders();
  //   var url =
  //       Uri.https(baseUrl, '/api/v1/store-mac-address/${headers['storeid']}');
  //   var response = await http.get(
  //     url,
  //     headers: headers,
  //   );
  //   var data = await jsonDecode(response.body);
  //   defaultPrinter =
  //       _devices.firstWhere((item) => item.address == data['ResponseData']);
  //   setState(() {
  //     defaultPrinter = defaultPrinter;

  //     print(_devices);
  //     print(macaddress);
  //   });
  //   return data['ResponseData'];
  // }

  void setPickedBy(pickedbyvalue) {
    setState(() {
      pickedBy = pickedbyvalue;
    });
  }

  void setDsicount(val) {
    val != null ? discountGiven = int.parse(val.toString()) : discountGiven = 0;
  }
  // save sale

  void saveSale() {
    // validation checks

    // if (selectedSaleType == '') {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please select sale type!'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }
    // end of validation checks

    // check overpayment
    if (Provider.of<ProductListProvider>(context, listen: false).totalpayment >
        Provider.of<ProductListProvider>(context, listen: false).totabill) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment cannot be more than the total bill!'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // end of overpayment check

    // end

    if (selectedCustomerId == "" &&
        Provider.of<ProductListProvider>(context, listen: false)
                .balancepayment() >
            0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select Customer or enter full payment'),
          backgroundColor: Colors.red,
        ),
      );
    }

    final balance = Provider.of<ProductListProvider>(context, listen: false)
        .balancepayment();
    final paymentlist =
        Provider.of<ProductListProvider>(context, listen: false).paymentlist;
    final totalbill =
        Provider.of<ProductListProvider>(context, listen: false).totabill;
    final products =
        Provider.of<ProductListProvider>(context, listen: false).productlist;
    final totalpayment =
        Provider.of<ProductListProvider>(context, listen: false).totalpayment;
    final customerNo =
        Provider.of<ProductListProvider>(context, listen: false).customerPhone;

    // post sale data
    PosSale saleData = new PosSale(
        ref2: customerNo.toString(),
        objType: 14,
        docNum: 2,
        pickedBy: pickedBy,
        cardCode:
            selectedCustomerId != '' ? int.parse(selectedCustomerId) : null,
        saleType: selectedSaleType != '' ? int.parse(selectedSaleType) : 0,
        discSum: discountGiven,
        payments: paymentlist,
        docTotal: totalbill,
        balance: balance,
        driver: selectedDriver != '' ? int.parse(selectedDriver) : 0,
        docDate: DateFormat('yyyy-MM-dd').parse(todayDate),
        rows: products,
        totalPaid: totalpayment,
        userName: cache['loggedInUserName']);
    // end of sale data post request
    print("Print sale data");
    setState(() {
      _isLoading = true;
    });

    // hit the provider method
    // Provider.of<GetProducts>(context, listen: false)
    //     .postsale(saleData)
    DatabaseHelper.instance.postSale(saleData).then((value) {
      // check if request was successful
      //if (value['ResultCode'] == 1200) {
      Provider.of<ProductListProvider>(context, listen: false)
          .setprodLIstempty();
      Provider.of<ProductListProvider>(context, listen: false)
          .resetCustmerPhone();
      Provider.of<ProductListProvider>(context, listen: false)
          .resetsetdiscount();

        setState(() {
          selectedSaleType = '';
          selectedCustomerId = "";
          _selectedCustomer = {};
          _isLoading = false;
        });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale successful!'),
          backgroundColor: Colors.green,
        ),
      );
      //   printingSaleReciept(defaultPrinter!, saleData, printerManager);
    }
        // end of the  success check

      // check if an error surfaced
      if (value['ResultCode'] == 1500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value['ResultDesc']),
            backgroundColor: Colors.red,
          ),
        );
      }
      // end of error check

      setState(() {
        _isLoading = false;
      });
    });

    // of of provider request method
  }

  @override
  void dispose() {
    // Close the database connection when the widget is disposed
    DatabaseHelper.instance.database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final responseCode = Provider.of<GetProducts>(context).responseCode;
    // final resultDesc = Provider.of<GetProducts>(context).resultDesc;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Center(
          child: Text(
            'Stalis Pos',
            style: TextStyle(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              cache = await _prefs.readCache(
                  'Token', 'StoreId', 'loggedInUserName', 'storename');
              await _prefs.removeCache(
                  'Token', 'StoreId', 'loggedInUserName', 'storename');
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: DatabaseHelper.instance.databaseConnection,
            child: Icon(
              Icons.sync,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: DatabaseHelper.instance.fetchAllInvoiceDetails,
            child: Icon(
              Icons.sync,
              color: Colors.red,
            ),
          )
        ],
      ),
      drawer: DrawerScreen(
        storename: storename,
      ),
      body: SingleChildScrollView(
          child: Stack(
            children:  [
              Column(
                children: [
                  SizedBox(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: _buildTodayDate(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              context
                                  .read<ProductListProvider>()
                                  .setPreviousRoute('/start');

                              Navigator.pushNamed(context, '/searchproduct');
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Sale Item')),
                        TextButton.icon(
                          onPressed: () {
                            context
                                .read<ProductListProvider>()
                                .setPreviousRoute('/start');

                            Navigator.pushNamed(context, '/paymentsearch');
                          },
                          icon: Icon(Icons.add),
                          label: Text('Add Payment'),
                          style: ButtonStyle(
                              foregroundColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.pink)),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Consumer<ProductListProvider>(
                      builder: (context, value, child) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: value.productlist.length,
                            itemBuilder: (context, index) => index <
                                value.productlist.length
                                ? Container(
                              color: Colors.white,
                              child: ListTile(
                                title: Text(
                                  value.productlist[index].name.toString(),
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Qty: ${(value.productlist[index].quantity).toString()}",
                                        style: TextStyle(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Price: ${value.productlist[index].price.toString()}",
                                        style: TextStyle(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      Text(formatnum
                                          .format(
                                          value.productlist[index].lineTotal)
                                          .toString()),
                                      Expanded(
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              value.removeProduct(index);
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                                : Card(
                              child: Text("No product added"),
                            ));
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.black54,
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
                    child: Text(
                      'Payments',
                      style: TextStyle(color: Colors.white),
                    ),
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Consumer<ProductListProvider>(
                      builder: (context, value, child) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: value.paymentlist.length,
                            itemBuilder: (context, index) => index <
                                value.paymentlist.length
                                ? Container(
                              color: Colors.white,
                              child: ListTile(
                                title: Text('${value.paymentlist[index].name}'),
                                subtitle: Text(
                                    '${value.paymentlist[index].paymentRemarks}'),
                                trailing: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                          "Ksh ${(formatnum.format(value.paymentlist[index].sumApplied)).toString()}"),
                                      Expanded(
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              value.removePayment(index);
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                                : Card(
                              child: Text("Hello"),
                            ));
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Bill:',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer<ProductListProvider>(
                          builder: (context, value, child) {
                            return Text(
                              '${formatnum.format(value.totalPrice())}',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Paid:',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Consumer<ProductListProvider>(
                            builder: (context, value, child) {
                              return Text(
                                '${formatnum.format(value.totalPaymentcalc())}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      )),
                  Consumer<ProductListProvider>(builder: (context, value, child) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${formatnum.format(value.balancepayment())}',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<ProductListProvider>(builder: (context, value, child) {
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              initialValue: "",
                              decoration: InputDecoration(
                                labelText: 'Picked By',
                                fillColor: Colors.white,
                                filled: false,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.blue, width: 1.0),
                                ),
                              ),
                              onChanged: (val) => {
                                setPickedBy(val),
                              },
                            ),
                          ),
                        );
                      }),
                      CustomSelectBox(
                          selectedVal: selectedSaleType,
                          label: 'Sale Type',
                          items: allSaleTypes,
                          onChanged: (val) {
                            setState(() {
                              selectedSaleType = val as String;
                            });
                          })
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: _isLoading ? CircularProgressIndicator() : ElevatedButton(
                          child: Text(
                            'Create Sale',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: saveSale,
                        ),
                      )
                    ],
                  )
                ],
              ),
              Positioned(child: _buildCustomerSection())
            ]
          )),
    );
  }


  Widget _buildCustomerSection() {
    return Stack(
      children: [
        Row(
          children: [
            Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 45.0),
              child: Column(
                children: [
                  const Divider(),
                  if (_selectedCustomer.isNotEmpty)
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 250,
                              child: Text(
                                _selectedCustomer['Name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            )
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            )
          ],
        ),
        Positioned(
          child: FocusScope(
            autofocus: true,
            child: SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCustomerSearchBox()
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCustomerSearchBox() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[200],
            width: 330,
            child: const Text('Search Customer'),
          ),
          SizedBox(
            height: 30,
            child: RawKeyboardListener(
              focusNode: _customerSearchFocusNode,
              child: TextFormField(
                focusNode: _customerNameFocusNode,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    contentPadding: const EdgeInsets.only(
                        bottom: 8.0, left: 10.0, top: 3.0)),
                controller: customerSearchController,
                onChanged: (value) {
                  _searchCustomers();
                },
              ),
            ),
          ),
          if (_customerFocusNodes.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              itemCount: _customers.length,
              itemBuilder: (ctx, i) {
                final isSelected = _currentIndex == i;
                final myFocusNode = _customerFocusNodes[i];
                myFocusNode.addListener(() {
                  if (myFocusNode.hasFocus) {
                    setState(() {
                      _currentIndex = i;
                      myFocusNode.requestFocus();
                    });
                  }
                });
                return RawKeyboardListener(
                  focusNode: myFocusNode,
                  onKey: (event) {
                    if (event is RawKeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter) {
                      //  _addRow(_customers[i], i);
                    }
                  },
                  child: Container(
                    color: isSelected ? Colors.blue : Colors.grey[600],
                    child: ListTile(
                      selectedTileColor: Colors.black,
                      title: Text(
                        _customers[i]['Name'],
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white),
                      ),
                      // subtitle: Text(
                      //     'Credit Limit: ${_customers[i]['creditLimit']}',
                      //     style: TextStyle(
                      //         color: isSelected ? Colors.white : Colors.white)),
                      // trailing: Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [Text('In Stock: ${_products[i]['AvailableQty']}', style: TextStyle(color: isSelected ? Colors.white : Colors.black))],
                      // ),
                      onTap: () {
                        print('selecting customer');
                        _selectCustomer(_customers[i]);
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }


  Widget _buildTodayDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Date:',
          style: paymentTextStyle,
        ),
        Text(
          todayDate,
          style: paymentTextStyle,
        )
      ],
    );
  }

//  build date picker
  Widget _buildDatePicker(BuildContext context) {
    return TextField(
      controller: dateController,
      decoration: const InputDecoration(
          icon: Icon(Icons.calendar_today), labelText: "Select Date"),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);

          setState(() {
            dateController.text = formattedDate.toString();
          });
        }
      },
    );
  }
// end of date picker
}
