import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/printservice.dart';

import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:intl/intl.dart';
import 'package:testproject/shared/drawerscreen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;

class CustomerDeposit extends StatefulWidget {
  const CustomerDeposit({Key? key}) : super(key: key);
  @override
  _CustomerDepositState createState() => _CustomerDepositState();
}

class _CustomerDepositState extends State<CustomerDeposit> {
  PrefService _prefs = PrefService();
  PrinterService _printerService = PrinterService();
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
  List _devices = [];
  var macaddress = '';

  final formatnum = new NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();

    setdate = true;
    _getPrinterAddress();
    sethenders();
    context.read<GetProducts>().fetchshopDetails();
    _generalSettingDetails = context.read<GetProducts>().generalSettingsDetails;
    /* _printerService.initPlatformState();
    _printerService.getPrinterAddress();
    _printerService.connect();
 */
    // initPlatformState();
    //fetchshopDetails();
    // sethenders();
  }

  void fetchshopDetails() async {
    var headers = await sethenders();

    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/general-settings');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('Sucessful POst');
    }
    _generalSettingDetails = jsonDecode(response.body)['ResponseData'];
    print("General Setting Data $_generalSettingDetails ");
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
    var url = Uri.https('apoyobackend.softcloudtech.co.ke',
        '/api/v1/store-mac-address/${headers['storeid']}');
    var response = await http.get(
      url,
      headers: headers,
    );
    var data = await jsonDecode(response.body);

    print('State Printer ${data['ResponseData']}');
    setState(() {
      macaddress = data['ResponseData'];
    });
    return data['ResponseData'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Center(
          child: Text(
            'Create Deposit',
            style: TextStyle(),
          ),
        ),
        actions: [
/* 
            Consumer<PrinterService>(
              builder: (context, value, child) {
                return FlatButton(
                    onPressed:
                        value.isconnected ? value.disconnect : value.connect,
                    child: Row(
                      children: [
                        Icon(
                          Icons.bluetooth,
                          color: value.isconnected ? Colors.green : Colors.red,
                        ),
                        Text(
                          _connected ? 'On' : 'Off',
                          style: TextStyle(
                              color: value.isconnected
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ],
                    ));
              },
            ), */
          // button width and height
          /*  Material(
              color: _connected ? Colors.red : Colors.green, // button color
              child: InkWell(
                splashColor: Colors.green, // splash color
                onTap: () {}, // button pressed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.bluetooth), // icon
                    Text(_connected ? 'Disconnect' : 'Connect',
                        style: TextStyle(color: Colors.white)), // text
                  ],
                ),
              ),
            ), */

          TextButton(
            onPressed: () async {
              cache = await _prefs.readCache(
                  'Token', 'StoreId', 'loggedInUserName', 'storename');
              print(cache['Token']);
              await _prefs.removeCache(
                  'Token', 'StoreId', 'loggedInUserName', 'storename');
              print(cache);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      /* persistentFooterButtons: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/searchproduct');
              },
              child: Text('Add Product')),
          TextButton(
              onPressed: _showaddPaymentPane, child: Text('Add Payment')),
          TextButton(
              onPressed: _showoutsourcedPane, child: Text('Add Outsourced')),
          TextButton(onPressed: () {}, child: Text('Save'))
        ], */
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'Add Products',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                    child: IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    context
                        .read<ProductListProvider>()
                        .setPreviousRoute('/customerDeposit');

                    Navigator.pushNamed(context, '/searchproduct');
                  },
                  icon: const Icon(
                    Icons.widgets_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
                )),
              ],
            ),
            Column(
              children: [
                Text(
                  'Add Payment',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                    child: IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    context
                        .read<ProductListProvider>()
                        .setPreviousRoute('/customerDeposit');

                    Navigator.pushNamed(context, '/paymentsearch');
                  },
                  icon: const Icon(
                    Icons.money,
                    color: Colors.white,
                    size: 35,
                  ),
                )),
              ],
            ),
            /* Column(
                children: [
                  Text(
                    'Add Sourced',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: IconButton(
                      enableFeedback: false,
                      onPressed: _showoutsourcedPane,
                      icon: const Icon(
                        Icons.widgets_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ), */
          ],
        ),
      ),
      drawer: DrawerScreen(
        storename: storename,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Consumer<ProductListProvider>(
                            builder: (context, value, child) {
                              return TextFormField(
                                  initialValue: (context
                                              .read<ProductListProvider>()
                                              .customerPhone !=
                                          '')
                                      ? context
                                          .read<ProductListProvider>()
                                          .customerPhone
                                      : '',
                                  decoration: InputDecoration(
                                      labelText: 'Customer Phone'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Customer Phone';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    context
                                        .read<ProductListProvider>()
                                        .setCustomerPhone(val);
                                  }

                                  /* setState(() {
                                    customerNo = val;
                                  }), */
                                  );
                            },
                          ),
                        ),
                        Expanded(
                          child: Consumer<ProductListProvider>(
                            builder: (context, value, child) {
                              return TextFormField(
                                controller: dateInput,
                                /* initialValue: (context
                                              .read<ProductListProvider>()
                                              .selectedDate !=
                                          '')
                                      ? context
                                          .read<ProductListProvider>()
                                          .selectedDate
                                      : '', */

                                //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons
                                        .calendar_today), //icon of text field
                                    labelText: 'Date' //label text of field
                                    ),
                                readOnly: true,
                                //set it true, so that user will not able to edit text
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      currentDate: DateTime.now(),
                                      //firstDate: DateTime(1900)
                                      firstDate: DateTime.now()
                                          .subtract(Duration(hours: 0)),
                                      //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2100));

                                  if (pickedDate != null) {
                                    print(
                                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    print(
                                        formattedDate); //formatted date output using intl package =>  2021-03-16
                                    setState(() {
                                      dateInput.text = formattedDate;
                                      setdate = false;
                                      value.setselectedDate(dateInput.text);
                                      //set output date to TextField value.
                                    });
                                  } else {
                                    DateTime now = new DateTime.now();
                                    DateTime date = new DateTime(
                                        now.year, now.month, now.day);
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd').format(date);
                                    setState(() {
                                      dateInput.text = formattedDate;
                                      value.setSaleDate(dateInput
                                          .text); //set output date to TextField value.
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Select Date';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ),
                      ]),
                  Consumer<ProductListProvider>(
                    builder: (context, value, child) {
                      return TextFormField(
                          initialValue: (context
                                      .read<ProductListProvider>()
                                      .customerName !=
                                  '')
                              ? context.read<ProductListProvider>().customerName
                              : '',
                          decoration:
                              InputDecoration(labelText: 'Customer Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Customer Phone';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            context
                                .read<ProductListProvider>()
                                .setCustomerName(val);
                          }

                          /* setState(() {
                                  customerNo = val;
                                }), */
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProductListProvider>(
              builder: (context, value, child) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: value.depositProductsList.length,
                    itemBuilder: (context, index) => index <
                            value.depositProductsList.length
                        ? Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(
                                value.depositProductsList[index].name
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Qty: ${(value.depositProductsList[index].quantity).toString()}",
                                      style: TextStyle(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Price: ${value.depositProductsList[index].price.toString()}",
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
                                        .format(value.depositProductsList[index]
                                            .lineTotal)
                                        .toString()),
                                    Expanded(
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              value.removeDepositProduct(index);
                                            });
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
          Consumer<ProductListProvider>(
            builder: (context, value, child) {
              return Container(
                height: 80.0,
                child: (value.depositPaymentList.length == 0)
                    ? Text("No payment added")
                    : ListView.builder(
                        itemCount: value.depositPaymentList.length,
                        itemBuilder: (context, index) => index <
                                value.depositPaymentList.length
                            ? Container(
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(
                                      '${value.depositPaymentList[index].name}'),
                                  trailing: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                            "Ksh ${(formatnum.format(value.depositPaymentList[index].sumApplied)).toString()}"),
                                        Expanded(
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  value.removeDepositPayment(
                                                      index);
                                                });
                                              }),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Card(
                                child: Text("Hello"),
                              )),
              );
            },
          ),
          Container(
            decoration: new BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                      MediaQuery.of(context).size.width, 40.0)),
            ),
            padding: EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (context.read<ProductListProvider>().totalDepositPaymentcalc() >
                        context.read<ProductListProvider>().totalDepositPrice())
                    ? Text(
                        'Payment can not be more than the Total',
                        style: TextStyle(color: Colors.red),
                      )
                    : SizedBox(
                        height: 10.0,
                      ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: Ksh',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer<ProductListProvider>(
                        builder: (context, value, child) {
                          return Text(
                            '${formatnum.format(value.totalDepositPrice())}',
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
                          'Payment: Ksh',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer<ProductListProvider>(
                          builder: (context, value, child) {
                            return Text(
                              '${formatnum.format(value.totalDepositPaymentcalc())}',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance: Ksh',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${formatnum.format(context.read<ProductListProvider>().depositbalance())}',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /* isloading
                            ? CircularProgressIndicator(
                                strokeWidth: 10.0,
                              )
                            :  */
                    Container(
                      child: ElevatedButton(
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          /* if (dateInput.text == null ||
                                  dateInput.text == '') {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Hi, I am a snack bar!"),
                                ));
                              } */

                          if (_formKey.currentState!.validate()) {
                            // print('Date  ...............${pickeddate}');

                            cache = await _prefs.readCache('Token', 'StoreId',
                                'loggedInUserName', 'storename');
                            if (context
                                    .read<ProductListProvider>()
                                    .totalDepositPayment >
                                context
                                    .read<ProductListProvider>()
                                    .totaDepositBill) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        )),
                                    height: 90.0,
                                    child: Center(
                                      child: Text(
                                        'Deposit made should not be more than total bill.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                ),
                              );
                            } else {
                              final depositBalance = context
                                  .read<ProductListProvider>()
                                  .depositbalance();
                              final depositPaymentList = context
                                  .read<ProductListProvider>()
                                  .depositPaymentList;
                              final totalDepositBill = context
                                  .read<ProductListProvider>()
                                  .totalDepositPrice();
                              final depositProductsList = context
                                  .read<ProductListProvider>()
                                  .depositProductsList;
                              final totalDepositpayments = context
                                  .read<ProductListProvider>()
                                  .totalDepositPaymentcalc();
                              final customerNo = context
                                  .read<ProductListProvider>()
                                  .customerPhone;

                              final customerName = context
                                  .read<ProductListProvider>()
                                  .customerName;

                              PosSale saleCard = new PosSale(
                                  ref2: customerNo.toString(),
                                  customerName: customerName,
                                  objType: 14,
                                  docNum: 2,
                                  discSum: 0,
                                  payments: depositPaymentList,
                                  docTotal: totalDepositBill,
                                  balance: depositBalance,
                                  docDate: DateFormat('yyyy-MM-dd')
                                      .parse(dateInput.text),
                                  rows: depositProductsList,
                                  totalPaid: totalDepositpayments,
                                  userName: cache['loggedInUserName']);

                              /* PosSale saleCard = new PosSale(
                                    ref2: customerNo.toString(),
                                    objType: 14,
                                    docNum: 2,
                                    discSum: 0,
                                    payments: paymentlist,
                                    docTotal: totalbill,
                                    balance: balance,
                                    docDate: DateFormat('yyyy-MM-dd')
                                        .parse(dateInput.text),
                                    rows: products,
                                    totalPaid: totalpayment,
                                    userName: cache['loggedInUserName']); */

                              context
                                  .read<GetProducts>()
                                  .postDepositSale(saleCard);
                              context
                                  .read<ProductListProvider>()
                                  .resetCustmerPhone();
                              context
                                  .read<ProductListProvider>()
                                  .resetCustomerName();

                               /*Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PrintPage(saleCard)));*/
                              context
                                  .read<ProductListProvider>()
                                  .setprodLIstempty();

                              context
                                  .read<ProductListProvider>()
                                  .setDepositListempty();
                              context
                                  .read<ProductListProvider>()
                                  .resetCustmerPhone();

                              Navigator.pushNamed(context, '/customerDeposit');
                            }
                          }
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}
