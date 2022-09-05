import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PrefService _prefs = PrefService();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  var cache;
  bool _connected = false;
  TextEditingController dateInput = TextEditingController();
  String saleType = '';
  bool setdate = true;
  String storename = '';
  List<SaleRow> products = [];
  String? customerNo;
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
    List<SaleRow> products = productsData.productlist;

    print('mac addresssssssssssss$macaddress');
    //final paymentlist = productsData.paymentlist;
    final totalbill = productsData.totalPrice();
    final balance = productsData.balancepayment();
    final totalpayment = productsData.totalPaymentcalc();
    final List<Payment> paymentlist = productsData.paymentlist;
    final printers = productsData.printers;

    return MaterialApp(
      home: Scaffold(
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
                    'Add Products',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: IconButton(
                      enableFeedback: false,
                      onPressed: () {
                        productsData.setPreviousRoute('/start');

                        Navigator.pushNamed(context, '/searchproduct');
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
                        productsData.setPreviousRoute('/start');

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
                          decoration: InputDecoration(hintText: 'Customer No'),
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
              setdate
                  ? Text(
                      'Please Select Date!',
                      style: TextStyle(color: Colors.red),
                    )
                  : Text(''),
              Expanded(
                child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) => index < products.length
                        ? Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(
                                products[index].name.toString(),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Qty: ${(products[index].quantity).toString()}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Price: ${products[index].sellingPrice.toString()}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(formatnum
                                        .format(products[index].lineTotal)
                                        .toString()),
                                    Expanded(
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              productsData.removeProduct(index);
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
              ),
              Container(
                height: 150.0,
                child: (paymentlist.length == 0)
                    ? Text("No payment added")
                    : ListView.builder(
                        itemCount: paymentlist.length,
                        itemBuilder: (context, index) =>
                            index < paymentlist.length
                                ? Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      title: Text('${paymentlist[index].name}'),
                                      trailing: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                                "Ksh ${(formatnum.format(paymentlist[index].sumApplied)).toString()}"),
                                            Expanded(
                                              child: IconButton(
                                                  icon: Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      productsData
                                                          .removePayment(index);
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
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: Ksh',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${formatnum.format(totalbill)}',
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
                        child: (totalpayment > totalbill)
                            ? Text(
                                'Payment can not be more than the Total',
                                style: TextStyle(color: Colors.red),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Payment: Ksh',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${formatnum.format(totalpayment)}',
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
                            'Balance: Ksh',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${formatnum.format(balance)}',
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

                            if (balance > 0) {
                              setState(() {
                                saleType = 'credit';
                              });
                            }
                            if (balance == 0) {
                              setState(() {
                                saleType = 'cash';
                              });
                            }
                            print('payment List $paymentlist');
                            if (totalpayment > totalbill) {
                            } else {
                              PosSale saleCard = new PosSale(
                                  ref2: customerNo,
                                  objType: 14,
                                  docNum: 2,
                                  discSum: 0,
                                  cardCode: 1,
                                  payments: paymentlist,
                                  docTotal: totalbill,
                                  balance: balance,
                                  docDate: DateFormat('yyyy-MM-dd')
                                      .parse(dateInput.text),
                                  rows: products,
                                  totalPaid: totalpayment,
                                  userName: cache['loggedInUserName']);
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

                              productsData.postsalearray(saleCard);

                              bluetooth.printCustom('2.N.K TELECOM', 1, 1);
                              bluetooth.printCustom(
                                  'Mobile Phones & Accessories -Karatina',
                                  0,
                                  2);
                              bluetooth.printCustom('Tel: 0780 048 175', 1, 1);
                              bluetooth.printCustom(
                                  'Our promise: If you bought from us then it is original',
                                  0,
                                  1);

                              if (saleCard.ref2 != null) {
                                bluetooth.printCustom(
                                    'Customer No ${saleCard.ref2!}', 0, 0);
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
                                    '    ${formatnum.format(currentElement.sellingPrice)}',
                                    '    ${formatnum.format(currentElement.lineTotal)}',
                                    0);
                                if (currentElement.ref1 != null) {
                                  bluetooth.printCustom(
                                      currentElement.ref1!, 0, 0);
                                }
                              }
                              bluetooth.print4Column('Total Bill:', '', ' ',
                                  '${formatnum.format(saleCard.docTotal)}', 0);

                              bluetooth.print4Column('Total Paid:', '', ' ',
                                  '${formatnum.format(saleCard.totalPaid)}', 0);

                              bluetooth.print4Column('Total Bal:', '', ' ',
                                  '${formatnum.format(saleCard.balance)}', 0);
                              bluetooth.printNewLine();
                              bluetooth.printCustom(
                                  'All phones have guarantee. Guarantee means either change or repair of phone. Dead phones will not be accepted back Whatsoever.Battery,screen, charger,liquid or mechanical damages have no warranty. If not assisted call 0720 222 444',
                                  0,
                                  1);

                              bluetooth.paperCut();
                              /* Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PrintPage(saleCard))); */
                              productsData.setprodLIstempty();

                              Navigator.pushNamed(context, '/start');
                            }
                          },
                          child: Text(
                            'Save',
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
