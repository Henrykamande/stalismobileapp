import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/previousRoute.dart';
import 'package:testproject/reusableComponents/bottomNavigation.dart';
import 'package:testproject/reusableComponents/drawer.dart';
import 'package:testproject/searchaccount.dart';
import 'package:testproject/main.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/outsourced.dart';
import 'package:testproject/print_page.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/searchproduct.dart';
import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:http/http.dart' as http;

class CustomerCreditNote extends StatefulWidget {
  @override
  _CustomerCreditNoteState createState() => _CustomerCreditNoteState();
}

class _CustomerCreditNoteState extends State<CustomerCreditNote> {
  PrefService _prefs = PrefService();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  var cache;
  bool _connected = false;
  TextEditingController dateInput = TextEditingController();
  String saleType = '';
  bool setdate = true;
  String storename = '';
  List<SaleRow> products = [];
  late String customerNo;
  late String customerName;
  var macaddress;
  final formatnum = new NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    products = [];
    setdate = true;
    _getPrinterAddress();
    sethenders();
    super.initState();
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

  void _showoutsourcedPane() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: OutsourcedProducts(),
          );
        });
  }

  void _showsearchproductPane() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SearchProduct(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);

    final salepost = Provider.of<GetProducts>(context);
    List<ReplacedProduct> replacementproductsList =
        productsData.replacementProductList;

    print('mac addresssssssssssss$macaddress');
    //final paymentlist = productsData.paymentlist;
    final depositBalance = productsData.depositbalance();
    final totalReturnpayments = productsData.totalReturnPayment;
    final totalReturncost = productsData.totalRetrunPrice();
    final totalReplacementCost = productsData.totalReplacementPrice();
    final topUpBalance = productsData.topUpBalanceCalc();
    final totalTopUpPayment = productsData.totalTopUpPaymentcalc();

    final List<Payment> depositPaymentList = productsData.depositPaymentList;
    final List<TopupPayment> topUpPayment = productsData.topUpPaymentList;
    final printers = productsData.printers;
    final returnProductList = productsData.returnProductList;
    print(totalReturnpayments);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Center(
          child: Text(
            'Credit Note',
            style: TextStyle(),
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () async {
              cache = await _prefs.readCache(
                  'Token', 'StoreId', 'loggedInUserName', 'storename');
              print(cache['Token']);
              await _prefs.removeCache(
                  'Token', 'StoreId', 'loggedInUserName', 'storename');
              print(cache);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Stalisapp()));
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
          color: Theme.of(context).primaryColor,
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
                  'Add Return',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      productsData.setPreviousRoute("/customercreditnote");
                      Navigator.pushNamed(
                        context,
                        '/searchproduct',
                      );
                    },
                    icon: const Icon(
                      Icons.widgets_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Add Replacement ',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      productsData
                          .setPreviousRoute("/customercreditnotereplacement");
                      Navigator.pushNamed(
                        context,
                        '/searchproduct',
                      );
                    },
                    icon: const Icon(
                      Icons.widgets_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
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
                      productsData.setPreviousRoute("/customercreditnote");
                      Navigator.pushNamed(context, '/paymentsearch');
                    },
                    icon: const Icon(
                      Icons.widgets_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
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
      drawer: Container(
        child: Drawer(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  child: DrawerHeader(
                    child: ListTile(
                      title: Text(storename),
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text(''),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/start');
                        },
                        icon: Icon(Icons.cancel),
                      ),
                    ),
                    decoration: BoxDecoration(),
                  ),
                ),
              ),
              ListTile(
                title: const Text('POS'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/start');
                },
              ),
              ListTile(
                title: const Text('Customer Deposit'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/customerDeposit');
                },
              ),
              ListTile(
                title: const Text('Return & Replacement'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/customercreditnote');
                },
              ),
              ListTile(
                title: const Text('Sold Products'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/soldproducts');
                },
              ),
              ListTile(
                title: const Text('Payments'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/salepayments');
                },
              ),
              ListTile(
                title: const Text('Returned Products'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/returnedproducts');
                },
              ),
              ListTile(
                title: const Text('SetUp Printer'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/defaultprinter');
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(hintText: 'Cust Phone No'),
                        onChanged: (val) => setState(() {
                          customerNo = val;
                        }),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                          controller: dateInput,

                          //editing controller of this TextField
                          decoration: InputDecoration(
                              icon: Icon(
                                  Icons.calendar_today), //icon of text field
                              labelText:
                                  '${dateInput.text}' //label text of field
                              ),
                          readOnly: true,
                          //set it true, so that user will not able to edit text
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate:
                                    DateTime.now().subtract(Duration(hours: 0)),
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
                                setdate =
                                    false; //set output date to TextField value.
                              });
                            } else {
                              DateTime now = new DateTime.now();
                              DateTime date =
                                  new DateTime(now.year, now.month, now.day);
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(date);
                              setState(() {
                                dateInput.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            }
                          }),
                    ),
                  ]),
            ),
            Container(
              height: 30.0,
              child: TextFormField(
                decoration: InputDecoration(hintText: 'Cust Name'),
                onChanged: (val) => setState(() {
                  customerName = val;
                }),
              ),
            ),
            setdate
                ? Text(
                    'Please Select Date!',
                    style: TextStyle(color: Colors.red),
                  )
                : Text(''),
            Expanded(
              child: ListView.builder(
                  itemCount: returnProductList.length,
                  itemBuilder: (context, index) => index <
                          returnProductList.length
                      ? ListTile(
                          title: Text(
                            returnProductList[index].productName.toString(),
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  "Qty: ${(returnProductList[index].quantity).toString()}",
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  "Price: ${returnProductList[index].sellingPrice.toString()}",
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              children: [
                                Text(formatnum
                                    .format(returnProductList[index].lineTotal)
                                    .toString()),
                                Expanded(
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          productsData
                                              .removeReturnProduct(index);
                                        });
                                      }),
                                )
                              ],
                            ),
                          ),
                        )
                      : Card(
                          child: Text("Hello"),
                        )),
            ),
            Container(
              height: 100.0,
              child: (replacementproductsList.length == 0)
                  ? Text("No Replacement added")
                  : ListView.builder(
                      itemCount: replacementproductsList.length,
                      itemBuilder: (context, index) => Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(
                                  '${replacementproductsList[index].productName}'),
                              subtitle: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      "Qty: ${(replacementproductsList[index].quantity).toString()}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      "Price: ${replacementproductsList[index].sellingPrice.toString()}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  children: [
                                    Text(formatnum
                                        .format(replacementproductsList[index]
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
                                              productsData
                                                  .removeReplacementProduct(
                                                      index);
                                            });
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),
            ),
            Container(
              decoration: new BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width, 40.0)),
              ),
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (topUpBalance > 0)
                      ? Text(
                          'Make payment for the top up',
                          style: TextStyle(color: Colors.red),
                        )
                      : Text(''),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Retrun: Ksh',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${formatnum.format(totalReturncost).toString()}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Replacement: Ksh',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${formatnum.format(totalReplacementCost).toString()}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment: Ksh',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${formatnum.format(totalTopUpPayment).toString()}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top up: Ksh',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${formatnum.format(topUpBalance).toString()}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.blue,
                        onPressed: () async {
                          /* if (dateInput.text == null ||
                                dateInput.text == '') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Hi, I am a snack bar!"),
                              ));
                            } */
                          AlertDialog(
                            content: Text('success'),
                          );

                          // print('Date  ...............${pickeddate}');
                          print(' Printer list on device  $printers');
                          print('Mac Address $macaddress');

                          cache = await _prefs.readCache('Token', 'StoreId',
                              'loggedInUserName', 'storename');
                          print(cache['loggedInUserName']);

                          if (depositBalance > 0) {
                            setState(() {
                              saleType = 'credit';
                            });
                          }
                          if (depositBalance == 0) {
                            setState(() {
                              saleType = 'cash';
                            });
                          }
                          print('payment List $depositPaymentList');
                          if (totalReturnpayments < 0) {
                          } else {
                            CreditMemo creditMemo = new CreditMemo(
                                topupPayments: topUpPayment,
                                customerName: customerName,
                                customerPhone: customerNo,
                                storeId: int.parse(cache['StoreId']),
                                returnedProducts: returnProductList,
                                replacedProducts: replacementproductsList);
                            //var printeraddress = salepost.getPrinterAddress();
                            // print(
                            //     'Printer address fron fuction $printeraddress');
                            try {
                              var activedevices =
                                  await bluetooth.getBondedDevices();
                              var existingprinter = activedevices.firstWhere(
                                  (itemToCheck) =>
                                      itemToCheck.address == macaddress);
                              void _connect() {
                                if (existingprinter != null) {
                                  print(
                                      'Selected device connect method $existingprinter');
                                  bluetooth.isConnected.then((isConnected) {
                                    print(isConnected);
                                    if (isConnected == false) {
                                      bluetooth
                                          .connect(existingprinter!)
                                          .catchError((error) {
                                        print(error);
                                        setState(() => _connected = false);
                                      });
                                      setState(() => _connected = true);
                                    }
                                  });
                                } else {
                                  show('No device selected.');
                                }
                              }

                              _connect();
                            } on PlatformException {}

                            // var existingprinter = null;

                            salepost.postCreditMemo(creditMemo);
                            bluetooth.printCustom('2.N.K TELECOM', 1, 1);
                            bluetooth.printCustom(
                                'Mobile Phones & Accessories -Karatina', 0, 2);
                            bluetooth.printCustom('Tel: 0780 048 175', 1, 1);
                            bluetooth.printCustom(
                                'Our promise: If you bought from us then it is original',
                                0,
                                1);

                            bluetooth.printCustom(
                                'Customer No: ${creditMemo.customerName}',
                                0,
                                0);
                            bluetooth.printCustom(
                                'Customer No: ${creditMemo.customerPhone}',
                                0,
                                0);
                            bluetooth.print3Column('Qty', 'Price', 'Total', 0);
                            for (var i = 0;
                                i < creditMemo.returnedProducts.length;
                                i++) {
                              //
                              var currentElement =
                                  creditMemo.returnedProducts[i];
                              bluetooth.printCustom(
                                  '${currentElement.productName}', 0, 0);
                              bluetooth.print3Column(
                                  '${currentElement.quantity}',
                                  '    ${formatnum.format(currentElement.sellingPrice)}',
                                  '    ${formatnum.format(currentElement.lineTotal)}',
                                  0);
                              if (currentElement.ref1 != null) {
                                bluetooth.printCustom(
                                    currentElement.ref1!, 0, 0);
                              }
                            }
                            bluetooth.print4Column(
                                'Total Return Cost:',
                                '',
                                ' ',
                                'Ksh ${formatnum.format(totalReturncost)}',
                                0);

                            bluetooth.print4Column(
                                'Total Replacement: ',
                                '',
                                ' ',
                                'Ksh ${formatnum.format(totalReplacementCost)}',
                                0);

                            bluetooth.print4Column(
                                'Top Up Payment :',
                                '',
                                ' ',
                                'Ksh ${formatnum.format(totalTopUpPayment)}',
                                0);
                            bluetooth.printNewLine();
                            bluetooth.printCustom(
                                'All phones have guarantee. Guarantee means either change or repair of phone. Dead phones will not be accepted back Whatsoever.Battery,screen, charger,liquid or mechanical damages have no warranty. If not assisted call 0720 222 444',
                                0,
                                1);
                            bluetooth.printNewLine();

                            bluetooth.paperCut();
                            /* Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PrintPage(saleCard))); */
                            productsData.setCreditNoteListempty();

                            Navigator.pushNamed(context, '/customercreditnote');
                          }
                        },
                        child: Text(
                          'Return/Replace',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
