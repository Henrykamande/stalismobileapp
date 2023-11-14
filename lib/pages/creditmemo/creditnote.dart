import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/previousRoute.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/reusableComponents/bottomNavigation.dart';
import 'package:testproject/reusableComponents/drawer.dart';
import 'package:testproject/pages/payment/searchaccount.dart';
import 'package:testproject/main.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/pages/outsourced/outsourced.dart';
import 'package:testproject/pages/printerPages/general_settings.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/pages/productsPages/searchproduct.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:testproject/shared/drawerscreen.dart';

class CustomerCreditNote extends StatefulWidget {
  @override
  _CustomerCreditNoteState createState() => _CustomerCreditNoteState();
}

class _CustomerCreditNoteState extends State<CustomerCreditNote> {
  PrefService _prefs = PrefService();
  PrinterService _printerService = PrinterService();

  final _formKey = GlobalKey<FormState>();

  var cache;
  bool _connected = false;
  TextEditingController dateInput = TextEditingController();

  String saleType = '';
  bool setdate = true;
  String storename = '';
  Map<String, dynamic> _generalSettingDetails = {};
  List<SaleRow> products = [];
  String customerNo = '';
  String customerName = '';
  var macaddress = "";
  final formatnum = new NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    products = [];
    setdate = true;

    _printerService.initPlatformState();
    _printerService.getPrinterAddress();
    // _printerService.connect();
    context.read<GetProducts>().fetchshopDetails();
    _generalSettingDetails = context.read<GetProducts>().generalSettingsDetails;
    /*  _getPrinterAddress();
    sethenders(); */
    fetchshopDetails();
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

/*   _getPrinterAddress() async {
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
 */
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);

    final salepost = Provider.of<GetProducts>(context);
    List<ReplacedProduct> replacementproductsList =
        productsData.replacementProductList;

    print('mac addresssssssssssss$macaddress');
    //final paymentlist = productsData.paymentlist;
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
          TextButton(
            onPressed: () async {
              cache = await _prefs.readCache(
                'Token',
                'StoreId',
                'loggedInUserName',
                'storename',
              );
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
                      Icons.money,
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(hintText: 'Cust Phone No'),
                                validator: (val) =>
                                    val!.isEmpty ? 'Customer Phone' : null,
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
                                      icon: Icon(Icons
                                          .calendar_today), //icon of text field
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
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                      setState(() {
                                        dateInput.text = formattedDate;
                                        setdate =
                                            false; //set output date to TextField value.
                                      });
                                    } else {
                                      DateTime now = new DateTime.now();
                                      DateTime date = new DateTime(
                                          now.year, now.month, now.day);
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
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 30.0,
                        child: TextFormField(
                          decoration: InputDecoration(hintText: 'Cust Name'),
                          validator: (val) =>
                              val!.isEmpty ? 'Customer Name' : null,
                          onChanged: (val) => setState(() {
                            customerName = val;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
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
                              '${replacementproductsList[index].productName.toString()}'),
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
                                              .removeReplacementProduct(index);
                                        });
                                      }),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            Container(
              height: 80.0,
              child: (topUpPayment.length == 0)
                  ? Text("No payment added")
                  : ListView.builder(
                      itemCount: topUpPayment.length,
                      itemBuilder: (context, index) => index <
                              topUpPayment.length
                          ? Container(
                              color: Colors.white,
                              child: ListTile(
                                title: Text(
                                    '${topUpPayment[index].paymentMode ?? ""}'),
                                trailing: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                          "Ksh ${(formatnum.format(topUpPayment[index].SumApplied ?? "")).toString()}"),
                                      Expanded(
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              productsData
                                                  .removeTopUpPayment(index);
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
                        Expanded(
                          child: Consumer<ProductListProvider>(
                            builder: (context, value, child) {
                              return Text(
                                'Total Return: Ksh ${formatnum.format(totalReturncost).toString()}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Total Rep: Ksh ${formatnum.format(totalReplacementCost).toString()}',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
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
                        Expanded(
                          child: Consumer<ProductListProvider>(
                            builder: (context, value, child) {
                              return Text(
                                'Top up: Ksh ${formatnum.format(topUpBalance).toString()}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Payment: Ksh ${formatnum.format(totalTopUpPayment).toString()}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
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
                              salepost.postCreditMemo(creditMemo);
                              _formKey.currentState?.reset();

                              productsData.setCreditNoteListempty();
                              productsData.setTopUpPaymentListEmpty();



                              Navigator.pushNamed(
                                  context, '/customercreditnote');
                            }
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
