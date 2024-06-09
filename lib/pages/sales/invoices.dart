import 'package:flutter/material.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:testproject/providers/shared_preferences_services.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/drawer_screen.dart';

class InvoicesScreen extends StatefulWidget {
  static const routeName = '/invoices-screen';

  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  PrefService _prefs = PrefService();

  late Future<List<Map<String, dynamic>>> invoices;
  Map<String, dynamic> _generalSettingDetails = {};

  final formatnum = new NumberFormat("#,##0.00", "en_US");
  int totalsold = 0;
  GetProducts _listbulder = GetProducts();
  TextEditingController dateInput = TextEditingController();
  String _searchquery = DateTime.now().toString();
  String storename = '';
  var solddata;
  var cache;
  var totalSales;

  Future<void> syncSales() async {
    await DatabaseHelper.instance.syncSales();
  }


  @override
  void initState() {
    invoices = DatabaseHelper.instance.getAllSaleInvoices()!;
    _generalSettingDetails = context.read<GetProducts>().generalSettingsDetails;

    super.initState();
    sethenders();
  }

  setSalesData(results) {
    totalSales = results;
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
  void dispose() {
    // Close the database connection when the widget is disposed
   // DatabaseHelper.instance.database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(_prefs.readCache('token','storeid'));
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerScreen(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
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
                        //pickedDate output format => 2021-03-10 00:00:00.000
                        String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                        //formatted date output using intl package =>  2021-03-16
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
              Text('Select Date'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                      onPressed: syncSales,
                      icon: Icon(Icons.sync),
                      label: Text('Sync sales')),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Container(
                    child: FutureBuilder<List<dynamic>>(
                        future: invoices,
                        //context
                        //     .read<GetProducts>()
                        //     .fetchSoldProducts(_searchquery),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {}
                          if (snapshot.hasData) {
                            List<dynamic> result = snapshot.data!;
                            //setSalesData(result);
                            print('result $result');
                            return (result != [])
                                ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: result.length,
                              itemBuilder: (context, index) => Card(
                                child: ListTile(
                                  title: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // Text(result[index]['card_code']
                                      //     .toString())
                                      Text('John K ')
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Invoice #"),
                                      result[index]['sale_status'] == 0 ? Icon(
                                        Icons.sync,
                                        color: Colors.orange,
                                      ) : Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    ],
                                  ),
                                  trailing: Column(
                                   crossAxisAlignment:  CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          "Bill: ${result[index]['doc_total'].toString()}"),
                                      Text(
                                          "Paid: ${result[index]['total_paid'].toString()}"),
                                      Text(
                                          "Balance: ${result[index]['balance'].toString()}"),

                                    ],
                                  ),
                                ),
                              ),
                            )
                                : Text('Select Date');
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          return Center(
                            child: Center(child: Text('')),
                          );
                        })),
              ),
              Consumer<GetProducts>(
                builder: (context, value, child) {
                  return FutureBuilder<int>(
                      future: context
                          .read<GetProducts>()
                          .getsoldtotals(_searchquery),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var result = snapshot.data!;

                          return (dateInput.text != '')
                              ? Text(
                            ('Total Sales : ${formatnum.format(result)}'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                              : Text('');
                        }
                        return Text('');
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
