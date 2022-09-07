import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:testproject/addProductForm.dart';
import 'package:testproject/models/product.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:testproject/providers/shared_preferences_services.dart';

class SoldProducts extends StatefulWidget {
  const SoldProducts({Key? key}) : super(key: key);

  @override
  State<SoldProducts> createState() => _SoldProductsState();
}

class _SoldProductsState extends State<SoldProducts> {
  late Future<List<dynamic>> soldproducts;
  PrefService _prefs = PrefService();
  final formatnum = new NumberFormat("#,##0.00", "en_US");
  int totalsold = 0;
  GetProducts _listbulder = GetProducts();
  TextEditingController dateInput = TextEditingController();
  String _searchquery = DateTime.now().toString();

  @override
  void initState() {
    soldproducts = _listbulder.fetchSoldProducts(_searchquery);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = Provider.of<GetProducts>(context);
    soldproducts = _listbulder.fetchSoldProducts(_searchquery);
    final totalSales = _listbulder.getsoldtotals(_searchquery);
    //print(_prefs.readCache('token','storeid'));
    return Scaffold(
      appBar: AppBar(
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
              Text('Select Date'),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                  child: FutureBuilder<List<dynamic>>(
                      future: soldproducts,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {}
                        if (snapshot.hasData) {
                          List<dynamic> result = snapshot.data!;
                          print(result);
                          print('rSold Products $result');

                          return (result != [])
                              ? ListView.builder(
                                  itemCount: result.length,
                                  itemBuilder: (context, index) => Card(
                                    child: ListTile(
                                      title: Text(result[index]['product']
                                              ['Name']
                                          .toString()),
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
                                      trailing: Text(
                                          "Total Ksh ${formatnum.format(result[index]['LineTotal']).toString()}"),
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
                      }),
                ),
              ),
              FutureBuilder<int>(
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
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
