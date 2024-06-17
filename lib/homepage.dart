import 'dart:convert';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testproject/constants/constants.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/pages/printer-pages/printerPage.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:intl/intl.dart';
import 'package:testproject/utils/shared_data.dart';
import 'package:testproject/widgets/custom_appbar.dart';
import 'package:testproject/widgets/drawer_screen.dart';

import 'package:http/http.dart' as http;
import 'package:testproject/utils/custom_select_box.dart';
import 'package:testproject/utils/http.dart';

import 'models/cart_payment.dart';
import 'models/cart_payment.dart';
import 'models/cart_payment.dart';

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

  List<dynamic> _accounts = [];

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

  List<TextEditingController> controllers = [];

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  PrinterBluetooth? _selectedPrinter;

  void _printReceipt(saleData) async {
    var address = await DatabaseHelper.instance.getDefaultPrinter();

    var printer = _devices.firstWhere((item) => item.address == address);

    printerManager.selectPrinter(printer!);

    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    // DEMO RECEIPT
    final PosPrintResult res = await printerManager
        .printTicket((await demoReceipt(paper, profile, saleData)));

    // showToast(res.msg);
  }

  Future<List<int>> demoReceipt(
      PaperSize paper, CapabilityProfile profile, saleData) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];

    // Print image
    // final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final Image? image = decodeImage(imageBytes);
    // bytes += ticket.image(image);

    bytes += ticket.text('SAWI PHONE HUB',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += ticket.text('MOBILE PHONES & ACCESSORIES',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('TEL: 0752768093',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('If you buy from us, know it is',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('original',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += ticket.text('--------------------------------',
        styles: PosStyles(align: PosAlign.center));

    bytes += ticket.row([
      PosColumn(text: 'Item   Description', width: 12),
    ]);

    bytes += ticket.text('--------------------------------',
        styles: PosStyles(align: PosAlign.center));

    for (var sale in saleData.rows) {
      bytes += ticket.row([
        PosColumn(text: '${sale.name}', width: 12),
      ]);

      bytes += ticket.row([
        PosColumn(text: '${sale.quantity} X ${sale.price} = ${sale.lineTotal}', width: 12),
      ]);

      bytes += ticket.text('--------------------------------',
          styles: PosStyles(align: PosAlign.center));
    }

    bytes += ticket.row([
      PosColumn(
          text: 'BILL: ${saleData.docTotal}',
          width: 12,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.row([
      PosColumn(
          text: 'PAID: ${saleData.totalPaid}',
          width: 12,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.row([
      PosColumn(
          text: 'BALC: ${saleData.balance}',
          width: 12,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.text('--------------------------------',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    // bytes += ticket.row([
    //   PosColumn(
    //       text: 'Cash',
    //       width: 7,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    //   PosColumn(
    //       text: '\$15.00',
    //       width: 5,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    // ]);
    // bytes += ticket.row([
    //   PosColumn(
    //       text: 'Change',
    //       width: 7,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    //   PosColumn(
    //       text: '\$4.03',
    //       width: 5,
    //       styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    // ]);

    bytes += ticket.feed(2);
    bytes += ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   bytes += ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // bytes += ticket.qrcode('example.com');

    ticket.feed(2);
    ticket.cut();
    return bytes;
  }

  @override
  void initState() {
    super.initState();
    setdate = true;

    fetchAccounts();

    printerManager.startScan(Duration(seconds: 2));

    printerManager.scanResults.listen((devices) async {
      print('UI: Devices found homepage ${devices.length}');
      setState(() {
        _devices = devices;
        if (_devices.length > 0) {
          _selectedPrinter = _devices[0];
        }
      });

      // printerManager.stopScan();
    });

    context.read<GetProducts>().fetchshopDetails();
    _generalSettingDetails = context.read<GetProducts>().generalSettingsDetails;
  }

  void fetchAccounts() {
    Provider.of<ProductListProvider>(context, listen: false)
        .fetchAccountsList();
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

  // Future<List<dynamic>> _getAccounts() async {
  //
  //   print(' accounts ----------');
  //
  //   var accounts = await DatabaseHelper.instance.getAllAccounts();
  //
  //   print(' accounts $accounts');
  //
  //   setState(() {
  //     _accounts = accounts!;
  //   });
  //
  //   return accounts;
  // }

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
    final paymentlist = Provider.of<ProductListProvider>(context, listen: false)
        .getAccountsData;

    final totalbill =
        Provider.of<ProductListProvider>(context, listen: false).totabill;

    final products =
        Provider.of<ProductListProvider>(context, listen: false).productlist;

    final totalpayment =
        Provider.of<ProductListProvider>(context, listen: false)
            .totalPaymentcalc();

    final customerNo =
        Provider.of<ProductListProvider>(context, listen: false).customerPhone;

    if (balance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot pay more than the bill'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

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

    List<CartPayment> salePayments = [];
    for (var payment in paymentlist) {
      if (payment.amount != '') {
        salePayments.add(payment);
      }
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
        payments: salePayments,
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

    DatabaseHelper.instance.postSale(saleData).then((value) {
      _printReceipt(saleData);

      // Provider.of<PrinterService>(context, listen: false).getBluetooth();

      // Provider.of<PrinterService>(context, listen: false).printSaleReceipt(saleData);

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
        controllers = [];
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

      fetchAccounts();
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
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      label: Text('test print')),
                  // TextButton.icon(
                  //   onPressed: () {
                  //     context
                  //         .read<ProductListProvider>()
                  //         .setPreviousRoute('/start');
                  //
                  //     Navigator.pushNamed(context, '/paymentsearch');
                  //   },
                  //   icon: Icon(Icons.add),
                  //   label: Text('Add Payment'),
                  //   style: ButtonStyle(
                  //       foregroundColor: MaterialStateColor.resolveWith(
                  //           (states) => Colors.pink)),
                  // )
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
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Qty: ${(value.productlist[index].quantity).toString()}",
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Price: ${value.productlist[index].price.toString()}",
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          Text(
                                              formatnum
                                                  .format(value
                                                      .productlist[index]
                                                      .lineTotal)
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        DataTable(
                          dividerThickness: 0,
                          border: const TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.white,
                              width: 0,
                            ),
                          ),
                          dataRowHeight: 40,
                          columnSpacing: 25,
                          columns: const [
                            DataColumn(
                              label: Text("Account"),
                            ),
                            DataColumn(
                              label: Text("Amount"),
                            )
                          ],
                          rows: Provider.of<ProductListProvider>(context,
                                  listen: false)
                              .getAccountsData
                              .map((item) {
                            var i = Provider.of<ProductListProvider>(context,
                                    listen: false)
                                .getAccountsData
                                .indexOf(item);

                            TextEditingController controller =
                                TextEditingController(
                                    text: item.amount.toString());
                            controllers.add(controller);

                            return DataRow(
                              cells: [
                                DataCell(Text(
                                  item.name.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                                DataCell(
                                  SizedBox(
                                    height: 35,
                                    child: Container(
                                      color: Colors.white,
                                      width: 200,
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                              EdgeInsets.only(bottom: 8.0),
                                        ),
                                        controller: controllers[i],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        key: Key(item.id.toString()),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            item.amount = value;
                                          });
                                          if (value.isEmpty) {
                                            setState(() {
                                              item.amount = "";
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Bill:',
                              style: paymentTextStyle,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Container(
                              child: Consumer<ProductListProvider>(
                                builder: (context, value, child) {
                                  return Text(
                                    '${formatnum.format(value.totalPrice())}',
                                    style: paymentTextStyle,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Paid:',
                              style: paymentTextStyle,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Consumer<ProductListProvider>(
                              builder: (context, value, child) {
                                return Text(
                                  '${formatnum.format(value.totalPaymentcalc())}',
                                  style: paymentTextStyle,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Balance:',
                              style: paymentTextStyle,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Consumer<ProductListProvider>(
                              builder: (context, value, child) {
                                return Text(
                                  '${formatnum.format(value.balancepayment())}',
                                  style: paymentTextStyle,
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
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
