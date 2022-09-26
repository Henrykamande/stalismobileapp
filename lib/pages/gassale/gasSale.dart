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
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:testproject/shared/drawerscreen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;

class GasSale extends StatefulWidget {
  const GasSale({Key? key}) : super(key: key);
  @override
  _GasSaleState createState() => _GasSaleState();
}

class _GasSaleState extends State<GasSale> {
  PrefService _prefs = PrefService();
  PrinterService _printerService = PrinterService();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
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

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;

            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
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
            'Gas Sale',
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

          FlatButton(
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
                        .setPreviousRoute('/gassale');

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
                        .setPreviousRoute('/gassale');

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
              child: Row(
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
                              decoration:
                                  InputDecoration(labelText: 'Customer Phone'),
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
                                icon: Icon(
                                    Icons.calendar_today), //icon of text field
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
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
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
                                DateTime date =
                                    new DateTime(now.year, now.month, now.day);
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
            ),
          ),
          Expanded(
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
                                      "Price: ${value.productlist[index].sellingPrice.toString()}",
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
                                            setState(() {
                                              value.removeProduct(index);
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
                child: (value.paymentlist.length == 0)
                    ? Text("No payment added")
                    : ListView.builder(
                        itemCount: value.paymentlist.length,
                        itemBuilder: (context, index) => index <
                                value.paymentlist.length
                            ? Container(
                                color: Colors.white,
                                child: ListTile(
                                  title:
                                      Text('${value.paymentlist[index].name}'),
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
                                                setState(() {
                                                  value.removePayment(index);
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
                (context.read<ProductListProvider>().totalPaymentcalc() >
                        context.read<ProductListProvider>().totalPrice())
                    ? Text(
                        'Payment can not be more than the Total',
                        style: TextStyle(color: Colors.red),
                      )
                    : SizedBox(
                        height: 10.0,
                      ),
                (context.read<ProductListProvider>().balancepayment() > 0)
                    ? Text(
                        'Balance can not be more than the 0',
                        style: TextStyle(color: Colors.red),
                      )
                    : Text(''),
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
                          'Payment: Ksh',
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
                        '${formatnum.format(context.read<ProductListProvider>().balancepayment())}',
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
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.blue,
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
                          print(
                              'showdetails -------------------------------------------------${_generalSettingDetails['CompanyName']}_');
                          AlertDialog(
                            content: Text('success'),
                          );
                          if (_formKey.currentState!.validate()) {
                            // print('Date  ...............${pickeddate}');

                            cache = await _prefs.readCache('Token', 'StoreId',
                                'loggedInUserName', 'storename');
                            if (context
                                    .read<ProductListProvider>()
                                    .totalpayment >
                                context.read<ProductListProvider>().totabill) {
                            } else {
                              final balance = context
                                  .read<ProductListProvider>()
                                  .balancepayment();
                              final paymentlist = context
                                  .read<ProductListProvider>()
                                  .paymentlist;
                              final totalbill =
                                  context.read<ProductListProvider>().totabill;
                              final products = context
                                  .read<ProductListProvider>()
                                  .productlist;
                              final totalpayment = context
                                  .read<ProductListProvider>()
                                  .totalpayment;
                              final customerNo = context
                                  .read<ProductListProvider>()
                                  .customerPhone;
                              PosSale saleCard = new PosSale(
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
                                  userName: cache['loggedInUserName']);

                              context.read<GetProducts>().postsale(saleCard);
                              context
                                  .read<ProductListProvider>()
                                  .resetCustmerPhone();

                              //salepost.setislodaing();

                              //var printeraddress = salepost.getPrinterAddress();
                              // print(
                              //     'Printer address fron fuction $printeraddress');

                              // var existingprinter = null;
                              bluetooth.printCustom(
                                  "${cache['storename']}", 1, 1);
                              bluetooth.printCustom(
                                  '${_generalSettingDetails['NotificationEmail']}',
                                  0,
                                  0);
                              bluetooth.printCustom(
                                  "Tel: ${_generalSettingDetails['CompanyPhone']}",
                                  1,
                                  1);

                              if (saleCard.ref2 != null) {
                                bluetooth.printCustom(
                                    'Customer No ${saleCard.ref2!}  Date : ${dateInput.text}',
                                    0,
                                    0);
                              }

                              bluetooth.print3Column(
                                  'Qty', 'Price', 'Total', 0);

                              for (var i = 0; i < saleCard.rows.length; i++) {
                                //
                                var currentElement = saleCard.rows[i];
                                bluetooth.printCustom(
                                    '${currentElement.name}', 0, 0);
                                bluetooth.print3Column(
                                    '${currentElement.quantity}',
                                    '${formatnum.format(currentElement.sellingPrice)}',
                                    '${formatnum.format(currentElement.lineTotal)}',
                                    1);
                                if (currentElement.ref1 != null) {
                                  bluetooth.printCustom(
                                      'Ref: ${currentElement.ref1!}', 0, 0);
                                }
                              }

                              bluetooth.printNewLine();
                              bluetooth.printCustom(
                                  'Total Bill:  ${formatnum.format(saleCard.docTotal)}',
                                  0,
                                  0);

                              bluetooth.printCustom(
                                  'Total Paid:  ${formatnum.format(saleCard.totalPaid)}',
                                  0,
                                  0);

                              bluetooth.printCustom(
                                  'Total Bal:  ${formatnum.format(saleCard.balance)}',
                                  0,
                                  0);
                              bluetooth.printNewLine();
                              bluetooth.printCustom(
                                  "${_generalSettingDetails['PhysicalAddress']}",
                                  0,
                                  1);
                              bluetooth.printNewLine();
                              bluetooth.printNewLine();

                              bluetooth.paperCut();
                              /*Navigator.of(context).push(MaterialPageRoute( 
                                  builder: (context) => PrintPage(saleCard)));*/
                              context
                                  .read<ProductListProvider>()
                                  .setprodLIstempty();
                              context
                                  .read<ProductListProvider>()
                                  .resetCustmerPhone();

                              Navigator.pushNamed(context, '/start');
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
