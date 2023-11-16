import 'dart:convert';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testproject/constants/constants.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/pages/printerPages/printerPage.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:intl/intl.dart';
import 'package:testproject/shared/drawerscreen.dart';

import 'package:http/http.dart' as http;
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
  var selecteddriver;

  var discountGiven = 0;
  var macaddress = '';
  var selectedSaleType; // Default selected value
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
    fetchallStores();
    fetchallSaleTypes();
    setdate = true;
    _getPrinterAddress();
    printerManager.scanResults.listen((devices) async {
      // print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });

    context.read<GetProducts>().fetchshopDetails();
    _generalSettingDetails = context.read<GetProducts>().generalSettingsDetails;
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

  void fetchallStores() async {
    var response = await httpGet('drivers');
    print(response.body);

    if (response.statusCode == 200) {}
    setState(() {
      alldrivers = jsonDecode(response.body)['ResponseData'];
      print("All Stores $alldrivers");
    });
    print("all stores $alldrivers");
  }

  void fetchallSaleTypes() async {
    var response = await httpGet('drivers');
    print(response.body);

    if (response.statusCode == 200) {}
    setState(() {
      allSaleTypes = jsonDecode(response.body)['ResponseData'];
      print("All Stores $allSaleTypes");
    });
    print("all stores $allSaleTypes");
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

  _getPrinterAddress() async {
    var headers = await sethenders();
    var url =
        Uri.https(baseUrl, '/api/v1/store-mac-address/${headers['storeid']}');
    var response = await http.get(
      url,
      headers: headers,
    );
    var data = await jsonDecode(response.body);

    setState(() {
      macaddress = data['ResponseData'];
    });
    return data['ResponseData'];
  }

  @override
  Widget build(BuildContext context) {
    final responseCode = Provider.of<GetProducts>(context).responseCode;
    final resultDesc = Provider.of<GetProducts>(context).resultDesc;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        ],
      ),
      drawer: DrawerScreen(
        storename: storename,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            child: _buildDatePicker(context),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
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
          Consumer<ProductListProvider>(builder: (context, value, child) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextFormField(
                  key: _formKey,
                  initialValue: "0",
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Discount Amount',
                    fillColor: Colors.white,
                    filled: false,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  ),
                  onChanged: (val) => setState(() {
                    value.addDiscount(double.parse(val.toString()));
                    val.length > 0
                        ? discountGiven = int.parse(val.toString())
                        : discountGiven = 0;
                  }),
                ),
              ),
            );
          }),
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
          Container(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              decoration: BoxDecoration(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton(
                              hint: Text(
                                'Select Shop',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: TextStyle(color: Colors.black),
                              isExpanded: false,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                              value: selecteddriver,
                              focusColor: Colors.white,
                              dropdownColor: Colors.white,
                              items: alldrivers.map((store) {
                                return DropdownMenuItem(
                                  value: store['id'],
                                  child: Text(
                                    store['Name'].toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selecteddriver = value;
                                });
                                print(value);
                              }),
                          DropdownButton(
                              hint: Text(
                                'Select Sale Type',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: TextStyle(color: Colors.black),
                              isExpanded: false,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                              value: selectedSaleType,
                              focusColor: Colors.white,
                              dropdownColor: Colors.white,
                              items: allSaleTypes.map((store) {
                                return DropdownMenuItem(
                                  value: store['id'],
                                  child: Text(
                                    store['Name'].toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSaleType = value;
                                });
                                print(value);
                              }),
                        ]),
                  ])),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: ElevatedButton(
                  child: Text(
                    'Create Sale',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    AlertDialog(
                      content: Text('success'),
                    );
                    printRecipt(printerManager, _devices);
                    cache = await _prefs.readCache(
                        'Token', 'StoreId', 'loggedInUserName', 'storename');
                    if (context.read<ProductListProvider>().totalpayment >
                        context.read<ProductListProvider>().totabill) {
                      customSnackBar(context,
                          "Payment cannot be more than the total bill");
                    } else if (context
                            .read<ProductListProvider>()
                            .totalpayment <=
                        0) {
                      customSnackBar(context, "Add Payment");
                    } else if (context
                            .read<ProductListProvider>()
                            .totalpayment <
                        context.read<ProductListProvider>().totalPrice()) {
                      customSnackBar(
                          context, "Balance Can not be greater than 0.");
                    } else {
                      final balance =
                          context.read<ProductListProvider>().balancepayment();
                      final paymentlist =
                          context.read<ProductListProvider>().paymentlist;
                      final totalbill =
                          context.read<ProductListProvider>().totabill;
                      final products =
                          context.read<ProductListProvider>().productlist;
                      final totalpayment =
                          context.read<ProductListProvider>().totalpayment;
                      final customerNo =
                          context.read<ProductListProvider>().customerPhone;
                      PosSale saleCard = new PosSale(
                          ref2: customerNo.toString(),
                          objType: 14,
                          docNum: 2,
                          saleType: selectedSaleType,
                          discSum: discountGiven,
                          payments: paymentlist,
                          docTotal: totalbill,
                          balance: balance,
                          driver: selecteddriver,
                          docDate: DateFormat('yyyy-MM-dd')
                              .parse(dateController.text),
                          rows: products,
                          totalPaid: totalpayment,
                          userName: cache['loggedInUserName']);

                      context.read<GetProducts>().postsale(saleCard);

                      if (responseCode == 1200) {
                        context.read<ProductListProvider>().setprodLIstempty();
                        context.read<ProductListProvider>().resetCustmerPhone();

                        customSnackBar(context, "Sale Posted Succesfully");
                        context.read<ProductListProvider>().resetsetdiscount();
                      } else {
                        customSnackBar(
                            context, "Sale Not Succesfully $resultDesc");
                      }
                      context.read<ProductListProvider>().setprodLIstempty();
                      context.read<ProductListProvider>().resetCustmerPhone();
                      context.read<ProductListProvider>().resetCustmerPhone();
                      context.read<ProductListProvider>().resetsetdiscount();

                      Navigator.pushNamed(context, '/start');
                    }
                  },
                ),
              )
            ],
          )
        ],
      )),
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
