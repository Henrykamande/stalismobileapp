import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testproject/constants/constants.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:intl/intl.dart';
import 'package:testproject/shared/drawerscreen.dart';

import 'package:http/http.dart' as http;

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
  List _devices = [];
  var macaddress = '';

  // var dateFormat = DateFormat("yyyy-MM-dd");
  // String todayDate = dateFormat.format(DateTime.now());

  TextEditingController dateController = TextEditingController();
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

    var url = Uri.https(baseUrl, '/api/v1/general-settings');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {}
    _generalSettingDetails = jsonDecode(response.body)['ResponseData'];
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
              TextButton.icon(onPressed: () {
                context
                    .read<ProductListProvider>()
                    .setPreviousRoute('/start');

                Navigator.pushNamed(context, '/searchproduct');
              }, icon: Icon(Icons.add), label: Text('Add Sale Item')),
              TextButton.icon(onPressed: () {
                context
                    .read<ProductListProvider>()
                    .setPreviousRoute('/start');

                Navigator.pushNamed(context, '/paymentsearch');
              }, icon: Icon(Icons.add), label: Text('Add Payment'),
              style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => Colors.pink)),)
            ],
          ),
          Container(
            color: Colors.white,
            child:  Consumer<ProductListProvider>(
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
          Container(
            color: Colors.black54,
            padding: EdgeInsets.symmetric(vertical:10.0, horizontal: 18.0),
            child: Text('Payments', style: TextStyle(color: Colors.white),),
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
                        title:
                        Text('${value.paymentlist[index].name}'),
                        subtitle: Text('${value.paymentlist[index].paymentRemarks}'),
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
          Padding(
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
                  '${formatnum.format(context.read<ProductListProvider>().balancepayment())}',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
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
                  /*  shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.blue, */
                  child: Text(
                    'Create Sale',
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
                                  'Payment cannot be more than the total bill',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                          ),
                        );
                      } else if (context
                          .read<ProductListProvider>()
                          .totalpayment <=
                          0) {
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
                                  'Add Payment',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                          ),
                        );
                      } else if (context
                          .read<ProductListProvider>()
                          .totalpayment <
                          context.read<ProductListProvider>().totabill) {
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
                                  'Payment canot be less than the total bill.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                          ),
                        );
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

                        if (responseCode == 1200) {
                          context
                              .read<ProductListProvider>()
                              .setprodLIstempty();
                          context
                              .read<ProductListProvider>()
                              .resetCustmerPhone();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    )),
                                height: 90.0,
                                child: Center(
                                  child: Text(
                                    'Sale Posted Succesfully .',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                            ),
                          );
                        } else {
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
                                    'Sale Not Succesfully $resultDesc',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                            ),
                          );
                        }

                        context
                            .read<ProductListProvider>()
                            .resetCustmerPhone();

                        //salepost.setislodaing();

                        //var printeraddress = salepost.getPrinterAddress();
                        // print(
                        //     'Printer address fron fuction $printeraddress');

                        // var existingprinter = null;
                        /* bluetooth.printCustom(
                                  "${cache['storename']}", 1, 1); */

                        Navigator.pushNamed(context, '/start');
                      }
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
