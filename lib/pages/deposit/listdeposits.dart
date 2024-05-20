import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testproject/pages/payment/addPayment.dart';
import 'package:testproject/models/depositPayment.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/shared/drawerscreen.dart';

class CustomerDepositsList extends StatefulWidget {
  const CustomerDepositsList({Key? key}) : super(key: key);

  @override
  State<CustomerDepositsList> createState() => _CustomerDepositsListState();
}

class _CustomerDepositsListState extends State<CustomerDepositsList> {
  PrefService _prefs = PrefService();

  bool _connected = false;

  late Future<List<dynamic>> soldproducts;
  final formatnum = new NumberFormat("#,##0.00", "en_US");
  int totalsold = 0;
  String storename = '';
  GetProducts _listbulder = GetProducts();
  TextEditingController dateInput = TextEditingController();
  String _searchquery = DateTime.now().toString();
  List _devices = [];
  var cache;

  @override
  void initState() {
    soldproducts = _listbulder.fetchSoldProducts(_searchquery);
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


  @override
  Widget build(BuildContext context) {
    final depositlist = _listbulder.fetchDeposits();
    //print(_prefs.readCache('token','storeid'));
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Container(
          child: Text('Customers Deposits'),
        ),
        elevation: 0.0,
      ),
      drawer: DrawerScreen(
        storename: storename,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              /*  Container(
                child: TextField(
                    controller: dateInput,
                    //editing controller of this TextField
                    decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText: DateFormat.yMMMMd()
                            .format(DateTime.now()) //label text of field
                        ),
                    readOnly: true,
                    //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
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
                          _searchquery = dateInput
                              .text; //set output date to TextField value.
                        });
                      } else {
                        /*  DateTime now = new DateTime.now();
                        DateTime date =
                            new DateTime(now.year, now.month, now.day);
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(date);
                        setState(() {
                          dateInput.text =
                              formattedDate; //set output date to TextField value.
                        }); */
                      }
                    }),
              ),
              Text('Select Date'), */

              Expanded(
                child: Container(
                    child: FutureBuilder<List<dynamic>>(
                        future: depositlist,
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {}
                          if (snapshot.hasData) {
                            List<dynamic> result = snapshot.data!;

                            return (snapshot.connectionState ==
                                    ConnectionState.active)
                                ? Center(
                                    child: Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: result.length,
                                    itemBuilder: (context, index) => Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          //leading: Icon(Icons.person),
                                          title: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              (result[index]['customerName'] !=
                                                          null) ||
                                                      (result[index][
                                                              'customerPhone'] !=
                                                          null)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.person,
                                                          color: Colors.orange,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "${result[index]['customerName'].toString()}",
                                                              ),
                                                              Text(
                                                                  "${result[index]['ref2'].toString()}")
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(''),
                                              // for (var i = 0;
                                              //     i > result[index]['rows'].length;
                                              //     i++)

                                              for (var item in result[index]
                                                  ['rows'])
                                                Text(
                                                  item['product']['Name']
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.green[500]),
                                                ),
                                              if (result[index]['ref1'] != null)
                                                Text(
                                                    "Serial/Ref: ${result[index]['ref1'].toString()}")

                                              /* Text(result[index]['rows']['product']
                                                      ['Name']
                                                  .toString()), */
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              Text(
                                                "Total Ksh ${formatnum.format(result[index]['DocTotal']).toString()}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.0),
                                              ),
                                              Text(
                                                "Deposit Ksh ${formatnum.format(result[index]['PaidSum']).toString()}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.0),
                                              ),
                                              Text(
                                                  "Balance Ksh ${formatnum.format(result[index]['Balance']).toString()}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.0)),
                                              /*  Text(
                                                  "Quantity Sold: ${result[index]['Quantity'].toString()}"),
                                              Row(
                                                children: [
                                                  (result[index]['ref2'] != null)
                                                      ? Text(
                                                          "Customer No: ${result[index]['ref2'].toString()}")
                                                      : Text(''),
                                                ],
                                              ),
                                              Text(
                                                "Total Ksh ${formatnum.format(result[index]['LineTotal']).toString()}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              
                                              
                                              ), */
                                            ],
                                          ),
                                          trailing: Column(
                                            children: [
                                              ElevatedButton(
                                                // style: ElevatedButton.styleFrom(
                                                //   primary:
                                                //       Colors.blue, // background
                                                //   onPrimary: Colors
                                                //       .white, // foreground
                                                // ),
                                                onPressed: () {
                                                  context
                                                      .read<
                                                          ProductListProvider>()
                                                      .selectedDepositItem(
                                                          result[index]);
                                                  context
                                                      .read<
                                                          ProductListProvider>()
                                                      .setPreviousRoute(
                                                          '/customerdepositlist');
                                                  Navigator.pushNamed(context,
                                                      '/paymentsearch');
                                                },
                                                child: Text('Add Payment'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        })),
              ),

              /*  FutureBuilder<int>(
                  future: totalSales,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.hasData);
                      var result = snapshot.data!;

                      return (dateInput.text != '')
                          ? Text(
                              ('Total Sales : ${formatnum.format(result)}'),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          : Text('');
                    }
                    return Text('');
                  }), */
            ],
          ),
        ),
      ),
    );
  }
}
