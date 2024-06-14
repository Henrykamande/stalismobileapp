import 'dart:convert';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testproject/constants/constants.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/pages/printer-pages/printerPage.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:intl/intl.dart';
import 'package:testproject/utils/shared_data.dart';
import 'package:testproject/widgets/custom_appbar.dart';
import 'package:testproject/widgets/drawer_screen.dart';

import 'package:http/http.dart' as http;
import 'package:testproject/utils/custom_select_box.dart';
import 'package:testproject/utils/http.dart';

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
  List<Map<String, dynamic>> _customers = [];
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

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 2));
  }
  //
  // void _setScannedDevices() {
  //
  //
  // }

  @override
  void initState() {
    super.initState();
    setdate = true;

    // _startScanDevices();

    // _getPrinterAddress();
    // print(' printers $_devices');


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
  Future<List<Map<String, dynamic>>> _searchCustomers() async {
    final searchQuery = customerSearchController.text;
    var customers = await DatabaseHelper.instance.searchCustomers(searchQuery);

    setState(() {
      _customers = customers!;
    });

    return customers!;
  }
  // end



  void fetchShopDetails() async {
   // var headers = await setHeaders();

    // var url = Uri.https(baseUrl, '/api/v1/general-settings');
    // var response = await http.get(
    //   url,
    //   headers: headers,
    // );
    //
    // if (response.statusCode == 200) {}
    // _generalSettingDetails = jsonDecode(response.body)['ResponseData'];
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

  setHeaders() async {
    var prefsData = await sharedData();

    var token = prefsData['token'];
    var storeId = prefsData['storeId'];
    var storeName = prefsData['storeName'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };
    setState(() {
      storename = storeName;
    });
    return headers;
  }

  _getPrinterAddress() async {
    _startScanDevices();

    var address = await DatabaseHelper.instance.getDefaultPrinter();

    printerManager.scanResults.listen((devices) async {

      print(' bluetooth devices $devices');

      var printer = devices.firstWhere((item) => item.address == address);
      setState(() {
        _devices = devices;
        defaultPrinter = printer;
      });
    });

    printerManager.stopScan();

  }

  void setPickedBy(pickedbyvalue) {
    setState(() {
      pickedBy = pickedbyvalue;
    });
  }

  void setDsicount(val) {
    val != null ? discountGiven = int.parse(val.toString()) : discountGiven = 0;
  }
  // save sale

  dynamic saveSale() async {
    var cartData =
        Provider.of<ProductListProvider>(context, listen: false).productlist;

    if (cartData.length <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must add at least one item to cart !'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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

      return;
    }

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

      return;
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

    var prefsData = await sharedData();

    var userName = prefsData['userName'];

    var allCustomers = await DatabaseHelper.instance.getAllCustomers();
    int cardCode = 0;

    if (allCustomers.isNotEmpty) {
      final firstCustomer = allCustomers.first;
      cardCode = firstCustomer['id'] as int;
    }

    if (selectedCustomerId != '') {
      cardCode = int.parse(selectedCustomerId);
    }


    // post sale data
    PosSale saleData = new PosSale(
        ref2: customerNo.toString(),
        objType: 14,
        docNum: 2,
        pickedBy: pickedBy,
        cardCode: cardCode,
        saleType: selectedSaleType != '' ? int.parse(selectedSaleType) : 0,
        discSum: discountGiven,
        payments: paymentlist,
        docTotal: totalbill,
        balance: balance,
        driver: selectedDriver != '' ? int.parse(selectedDriver) : 0,
        docDate: DateFormat('yyyy-MM-dd').parse(todayDate),
        rows: products,
        totalPaid: totalpayment,
        userName: userName);


    setState(() {
      _isLoading = true;
    });

    if(defaultPrinter == null) {
      _getPrinterAddress();
      print(' fetched bluetooth ');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set the default printer first'),
          backgroundColor: Colors.red,
        ),
      );
    }

    DatabaseHelper.instance.postSale(saleData).then((value) {
      setState(() {
        _isLoading = false;
      });

      if(defaultPrinter != null) {
        printingSaleReciept(defaultPrinter!, saleData, printerManager);
      }

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

      // end of the  success check

      // // check if an error surfaced
      //  if (value['ResultCode'] == 1500) {
      //    ScaffoldMessenger.of(context).showSnackBar(
      //      SnackBar(
      //        content: Text(value['ResultDesc']),
      //        backgroundColor: Colors.red,
      //      ),
      //    );
      //  }
      //  end of error check
      //
      //    setState(() {
      //      _isLoading = false;
      //    });
    });

    // of of provider request method
  }

  @override
  void dispose() {
    // Close the database connection when the widget is disposed
    // DatabaseHelper.instance.database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final responseCode = Provider.of<GetProducts>(context).responseCode;
    // final resultDesc = Provider.of<GetProducts>(context).resultDesc;

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerScreen(),
      body: SingleChildScrollView(
          child: Stack(children: [
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
                      itemBuilder: (context, index) =>
                          index < value.productlist.length
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
                                              .format(value
                                                  .productlist[index].lineTotal)
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
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.0),
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
                // CustomSelectBox(
                //     selectedVal: selectedSaleType,
                //     label: 'Sale Type',
                //     items: allSaleTypes,
                //     onChanged: (val) {
                //       setState(() {
                //         selectedSaleType = val as String;
                //       });
                //     })
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
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
      ])),
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
                                'Client : ${_selectedCustomer['Name']}',
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
                          children: [_buildCustomerSearchBox()],
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
          if (_customers.length > 0)
            ListView.builder(
              shrinkWrap: true,
              itemCount: _customers.length,
              itemBuilder: (ctx, i) {
                final isSelected = _currentIndex == i;
                return Container(
                  color: isSelected ? Colors.blue : Colors.grey[600],
                  child: ListTile(
                    selectedTileColor: Colors.black,
                    title: Text(
                      _customers[i]['Name'],
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white),
                    ),
                    onTap: () {
                      _selectCustomer(_customers[i]);
                    },
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
