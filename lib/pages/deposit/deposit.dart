import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testproject/models/previousRoute.dart';
import 'package:testproject/main.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/postSale.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';

import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:http/http.dart' as http;
import 'package:testproject/shared/drawerscreen.dart';

class CustomerDeposit extends StatefulWidget {
  @override
  _CustomerDepositState createState() => _CustomerDepositState();
}

class _CustomerDepositState extends State<CustomerDeposit> {
  PrefService _prefs = PrefService();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
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
  String customerNo = "";
  var macaddress = "";
  final formatnum = new NumberFormat("#,##0.00", "en_US");
  String customerName = "";

  @override
  void initState() {
    products = [];
    setdate = true;

    _printerService.initPlatformState();
    _printerService.getPrinterAddress();
    _printerService.connect();
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

  /* _getPrinterAddress() async {
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
    final productData = Provider.of<ProductListProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Center(
          child: Text(
            'Customer Deposit',
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
                      context
                          .read<ProductListProvider>()
                          .setPreviousRoute("/customerDeposit");
                      Navigator.pushNamed(context, '/searchproduct',
                          arguments:
                              PreviousRoute(routeString: "/customerDeposit"));
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
                      context
                          .read<ProductListProvider>()
                          .setPreviousRoute("/customerDeposit");
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
      drawer: DrawerScreen(
        storename: storename,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Consumer<ProductListProvider>(
                              builder: (context, value, child) {
                                return TextFormField(
                                  decoration: InputDecoration(
                                      hintText: 'Cust Phone No'),
                                  validator: (val) =>
                                      val!.isEmpty ? 'Customer Phone' : null,
                                  onChanged: (val) => setState(() {
                                    customerNo = val;
                                  }),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: TextField(
                                controller: dateInput,

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
                    padding: const EdgeInsets.all(3.0),
                    child: Consumer<ProductListProvider>(
                      builder: (context, value, child) {
                        return TextFormField(
                          decoration: InputDecoration(hintText: 'Cust Name'),
                          validator: (val) =>
                              val!.isEmpty ? 'Customer Name' : null,
                          onChanged: (val) => setState(() {
                            customerName = val;
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            setdate
                ? Text(
                    'Please Select Date!',
                    style: TextStyle(color: Colors.red),
                  )
                : Text(''),
            Expanded(child: Consumer<ProductListProvider>(
              builder: (context, value, child) {
                return ListView.builder(
                    itemCount: value.depositProductsList.length,
                    itemBuilder: (context, index) => index <
                            value.depositProductsList.length
                        ? ListTile(
                            title: Text(
                              value.depositProductsList[index].name.toString(),
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Qty: ${(value.depositProductsList[index].quantity).toString()}",
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    "Price: ${value.depositProductsList[index].sellingPrice.toString()}",
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
                                      .format(value
                                          .depositProductsList[index].lineTotal)
                                      .toString()),
                                  Expanded(
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<ProductListProvider>()
                                              .removeDepositProduct(index);
                                        }),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Card(
                            child: Text("Hello"),
                          ));
              },
            )),
            Consumer<ProductListProvider>(
              builder: (context, value, child) {
                return Container(
                  height: 100.0,
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
                                                  value.removeDepositPayment(
                                                      index);
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
                        Consumer<ProductListProvider>(
                          builder: (context, value, child) {
                            return Text(
                              '${formatnum.format(value.totalDepositPrice())}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: (context
                                  .read<ProductListProvider>()
                                  .totalDepositPaymentcalc() >
                              context
                                  .read<ProductListProvider>()
                                  .totalDepositPrice())
                          ? Text(
                              'Payment can not be more than the Total',
                              style: TextStyle(color: Colors.red),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment: Ksh',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Consumer<ProductListProvider>(
                                  builder: (context, value, child) {
                                    return Text(
                                      '${formatnum.format(value.totalDepositPaymentcalc())}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
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
                        Consumer<ProductListProvider>(
                          builder: (context, value, child) {
                            return Text(
                              '${formatnum.format(value.depositbalance())}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
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
                            if (_formKey.currentState!.validate()) {
                              // print('Date  ...............${pickeddate}');
                              print('Mac Address $macaddress');

                              cache = await _prefs.readCache('Token', 'StoreId',
                                  'loggedInUserName', 'storename');

                              if (context
                                      .read<ProductListProvider>()
                                      .totalDepositPaymentcalc() >
                                  context
                                      .read<ProductListProvider>()
                                      .totalDepositPrice()) {
                              } else {
                                /* final customerNo = context
                                    .read<ProductListProvider>()
                                    .customerPhone; */
                                final depositProductsList = context
                                    .read<ProductListProvider>()
                                    .depositProductsList;
                                final totalDepositpayments = context
                                    .read<ProductListProvider>()
                                    .totalDepositPaymentcalc();

                                final totalDepositBill = context
                                    .read<ProductListProvider>()
                                    .totalDepositPrice();

                                /* final customerName = context
                                    .read<ProductListProvider>()
                                    .customerName; */
                                final depositBalance = context
                                    .read<ProductListProvider>()
                                    .depositbalance();

                                final depositPaymentList = context
                                    .read<ProductListProvider>()
                                    .depositPaymentList;
                                PosSale saleCard = new PosSale(
                                    ref2: customerNo,
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
                                //var printeraddress = salepost.getPrinterAddress();
                                // print(
                                //     'Printer address fron fuction $printeraddress');
                                context
                                    .read<GetProducts>()
                                    .postDepositSale(saleCard);
                                context
                                    .read<ProductListProvider>()
                                    .setDepositListempty();
                                productData.resetCustmerPhone();

                                productData.resetCustomerName();
                                context
                                    .read<ProductListProvider>()
                                    .setDepositListempty();
                                _formKey.currentState?.reset();

                                // var existingprinter = null;

                                bluetooth.printCustom(
                                    "${cache['storename']}", 1, 1);
                                bluetooth.printCustom(
                                    '${_generalSettingDetails['NotificationEmail']}',
                                    0,
                                    2);
                                bluetooth.printCustom(
                                    "Tel: ${_generalSettingDetails['CompanyPhone']}",
                                    1,
                                    1);

                                if (saleCard.ref2 != null) {
                                  bluetooth.printCustom(
                                      'Customer No ${saleCard.ref2!}  Date : ${dateInput.text} ',
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
                                      '    ${formatnum.format(currentElement.sellingPrice)}',
                                      '    ${formatnum.format(currentElement.lineTotal)}',
                                      0);
                                  if (currentElement.ref1 != null) {
                                    bluetooth.printCustom(
                                        currentElement.ref1!, 0, 0);
                                  }
                                }

                                bluetooth.print4Column(
                                    'Total Bill:',
                                    '',
                                    ' ',
                                    '${formatnum.format(saleCard.docTotal)}',
                                    0);

                                bluetooth.print4Column(
                                    'Total Paid:',
                                    '',
                                    ' ',
                                    '${formatnum.format(saleCard.totalPaid)}',
                                    0);

                                bluetooth.print4Column('Total Bal:', '', ' ',
                                    '${formatnum.format(saleCard.balance)}', 0);
                                bluetooth.printNewLine();
                                bluetooth.printCustom(
                                    "${_generalSettingDetails['PhysicalAddress']}",
                                    0,
                                    1);

                                bluetooth.paperCut();
                                /* Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PrintPage(saleCard))); */
                                productData.resetCustmerPhone();

                                productData.resetCustomerName();
                                context
                                    .read<ProductListProvider>()
                                    .setDepositListempty();

                                Navigator.pushNamed(
                                    context, '/customerdeposit');
                              }
                            }
                          },
                          child: Text(
                            'Create Deposit',
                            style: TextStyle(color: Colors.white),
                          ))
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
}
