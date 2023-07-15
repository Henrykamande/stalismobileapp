import 'package:flutter/material.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:testproject/providers/shared_preferences_services.dart';

class SoldProducts extends StatefulWidget {
  const SoldProducts({Key? key}) : super(key: key);

  @override
  State<SoldProducts> createState() => _SoldProductsState();
}

class _SoldProductsState extends State<SoldProducts> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  PrefService _prefs = PrefService();

  late Future<List<dynamic>> soldproducts;
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

  @override
  void initState() {
    soldproducts = _listbulder.fetchSoldProducts(_searchquery);
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
  Widget build(BuildContext context) {
    //print(_prefs.readCache('token','storeid'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Container(
          child: Text('Sold Products'),
        ),
        elevation: 0.0,
      ),
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
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                    child: FutureBuilder<List<dynamic>>(
                        future: context
                            .read<GetProducts>()
                            .fetchSoldProducts(_searchquery),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {}
                          if (snapshot.hasData) {
                            List<dynamic> result = snapshot.data!;
                            //setSalesData(result);

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
                                            Text(result[index]['product']
                                                    ['Name']
                                                .toString()),
                                            (result[index]['ref1'] != null)
                                                ? Text(
                                                    "Serial/Ref: ${result[index]['ref1'].toString()}")
                                                : Text(''),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Quantity Sold: ${result[index]['Quantity'].toString()}"),
                                            Row(
                                              children: [
                                                (result[index]['ref2'] != null)
                                                    ? Text(
                                                        "Customer No: ${result[index]['ref2'].toString()}")
                                                    : Text(''),
                                              ],
                                            )
                                          ],
                                        ),
                                        trailing: Column(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  "Total Ksh ${formatnum.format(result[index]['LineTotal']).toString()}"),
                                            ),
                                            Expanded(
                                              child: IconButton(
                                                onPressed: () {
                                                  bluetooth.printCustom(
                                                      '${cache['storename']}',
                                                      1,
                                                      1);
                                                  bluetooth.printCustom(
                                                      '${_generalSettingDetails['NotificationEmail']}',
                                                      0,
                                                      1);
                                                  bluetooth.printCustom(
                                                      'Tel: ${_generalSettingDetails['CompanyPhone']}',
                                                      1,
                                                      1);

                                                  bluetooth.printCustom(
                                                      'Date : ${dateInput.text}',
                                                      0,
                                                      1);

                                                  if (result[index]['ref2'] !=
                                                      null) {
                                                    bluetooth.printCustom(
                                                        'Customer No ${result[index]['ref2']}  ',
                                                        0,
                                                        1);
                                                  }
                                                  bluetooth.printNewLine();

                                                  bluetooth.printCustom(
                                                      'Qty              Price    Total',
                                                      1,
                                                      0);

                                                  bluetooth.printCustom(
                                                      '${result[index]['product']['Name']}',
                                                      0,
                                                      0);

                                                  bluetooth.printCustom(
                                                      "${result[index]['Quantity']}                      ${result[index]['Price']}        ${result[index]['LineTotal']}",
                                                      0,
                                                      0);
                                                  bluetooth.printCustom(
                                                      '${result[index]['ref1']}',
                                                      0,
                                                      0);
                                                  /* for (var i = 0;
                                                      i <
                                                          result[index]
                                                              .rows
                                                              .length;
                                                      i++) {
                                                    //
                                                    var currentElement =
                                                        result[index].rows[i];
                                                    bluetooth.printCustom(
                                                        '${currentElement.name}',
                                                        0,
                                                        0);
                                                    bluetooth.print3Column(
                                                        '${currentElement.quantity}',
                                                        '${formatnum.format(currentElement['sellingPrice'])}',
                                                        '${formatnum.format(currentElement['lineTotal]'])}',
                                                        1);
                                                    if (currentElement['ref1'] !=
                                                        null) {
                                                      bluetooth.printCustom(
                                                          'Ref: ${currentElement['ref1']}',
                                                          0,
                                                          0);
                                                    } */
                                                  bluetooth.printNewLine();

                                                  bluetooth.printCustom(
                                                      'Total Bill:  ${formatnum.format(result[index]['document']['DocTotal']).toString()}',
                                                      0,
                                                      0);

                                                  bluetooth.printCustom(
                                                      'Total Paid: ${formatnum.format(result[index]['document']['PaidSum']).toString()}',
                                                      0,
                                                      0);

                                                  bluetooth.printCustom(
                                                      'Total Bal: ${formatnum.format(result[index]['document']['Balance']).toString()}',
                                                      0,
                                                      0);
                                                  bluetooth.printNewLine();

                                                  bluetooth.printCustom(
                                                      '${_generalSettingDetails['PhysicalAddress']}',
                                                      0,
                                                      1);

                                                  bluetooth.printNewLine();
                                                  bluetooth.printQRcode(
                                                      "Stalis Pos",
                                                      200,
                                                      200,
                                                      1);
                                                  bluetooth.printNewLine();
                                                  bluetooth.printNewLine();
                                                  bluetooth.printNewLine();

                                                  bluetooth.paperCut();
                                                },
                                                icon: Column(
                                                  children: [
                                                    Expanded(
                                                      child: Icon(
                                                        Icons.print,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
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
              Consumer<GetProducts>(
                builder: (context, value, child) {
                  return ElevatedButton(
                      onPressed: () {
                        bluetooth.printCustom('${cache['storename']}', 1, 1);
                        bluetooth.printCustom(
                            '${_generalSettingDetails['NotificationEmail']}',
                            0,
                            1);
                        bluetooth.printCustom(
                            'Tel: ${_generalSettingDetails['CompanyPhone']}',
                            1,
                            1);

                        bluetooth.printCustom('Date : ${dateInput.text}', 0, 1);

                        bluetooth.printCustom(
                            'Qty              Price    Total', 1, 0);
                        for (int index = 0;
                            index < value.soldProducrs.length;
                            index++) {
                          bluetooth.printCustom(
                              '${value.soldProducrs[index]['product']['Name']}',
                              0,
                              0);

                          bluetooth.printCustom(
                              "${value.soldProducrs[index]['Quantity']}                      ${value.soldProducrs[index]['Price']}        ${value.soldProducrs[index]['LineTotal']}",
                              0,
                              0);
                          bluetooth.printCustom(
                              '${value.soldProducrs[index]['ref1']}', 0, 0);

                          bluetooth.printNewLine();
                        }
                        bluetooth.printCustom(
                            'Total Sales:  ${formatnum.format(value.dailytotalsales).toString()}',
                            0,
                            0);

                        bluetooth.printNewLine();

                        bluetooth.printCustom(
                            '${_generalSettingDetails['PhysicalAddress']}',
                            0,
                            1);

                        bluetooth.printNewLine();
                        bluetooth.printQRcode("Stalis Pos", 200, 200, 1);
                        bluetooth.printNewLine();
                        bluetooth.printNewLine();
                        bluetooth.printNewLine();

                        bluetooth.paperCut();
                      },
                      child: Text("Print Sold Products"));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
