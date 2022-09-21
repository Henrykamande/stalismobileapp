import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:testproject/providers/shared_preferences_services.dart';

class ReturnProducts extends StatefulWidget {
  const ReturnProducts({Key? key}) : super(key: key);

  @override
  State<ReturnProducts> createState() => _ReturnProductsState();
}

class _ReturnProductsState extends State<ReturnProducts> {
  late Future<List<dynamic>> returnedProducts;
  late Future<List<dynamic>> totalpayment;
  String _datequery = "";
  var datapayment;
  var data;
  GetProducts _returnedProducts = GetProducts();
  TextEditingController dateInput = TextEditingController();
  PrefService _prefs = PrefService();
  final formatnum = new NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    _returnedProducts.fetchReturnedProducts(_datequery);
    getTotalPayments(_datequery);
    super.initState();
  }

  sethenders() async {
    var cache = await _prefs.readCache(
        'Token', 'StoreId', 'loggedinUserName', 'storename');

    String token = cache['Token'];
    String storeId = cache['StoreId'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };
    return headers;
  }

  getTotalPayments(query) async {
    var headers = sethenders();
    final queryparameters = jsonEncode({
      "storeid": "${headers['storeid']}",
      "StartDate": "$query",
      "EndDate": "$query",
    });

    var url = Uri.https(
        'apoyobackend.softcloudtech.co.ke', '/api/v1/sale-payments-report');
    var response = await http.post(
      url,
      headers: headers,
      body: queryparameters,
    );
    if (response.statusCode == 200) {
      data = await jsonDecode(response.body)['ResponseData']['TotalAmount'];
      /* TotalAmountData totalpaymentdata =
          data.map((dynamic item) => TotalAmountData.fromJson(item)).toList(); */
      setState(() {
        datapayment = data;
      });

      return datapayment;
    } else {
      throw 'Cant get total payment';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = Provider.of<GetProducts>(context);
    returnedProducts = _returnedProducts.fetchReturnedProducts(_datequery);
    //datapayment = _paymentlistbulder.getTotalPayments(_datequery);

    //print(salepayment);
    //print(_prefs.readCache('token','storeid'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Container(
          child: Text('Returned Products'),
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
                          _datequery = dateInput
                              .text; //set output date to TextField value.
                        });
                      }
                    }),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                  child: FutureBuilder<List<dynamic>>(
                      future: returnedProducts,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Text("No Returns");
                        }
                        if (snapshot.hasData) {
                          print(returnedProducts);
                          List<dynamic> result = snapshot.data!;

                          return (result.isEmpty)
                              ? Text("No Returns")
                              : ListView.builder(
                                  itemCount: result.length,
                                  itemBuilder: (context, index) => (result
                                          .isEmpty)
                                      ? Text('No returns')
                                      : InkWell(
                                          onTap: () {
                                            //print(result[index]['name']);

                                            /* final selectedproduct = new ResponseDatum(
                                        sellingPrice: (result[index]
                                            ['SellingPrice']),
                                        availableQty: (result[index]
                                            ['AvailableQty']),
                                        o_p_l_n_s_id: (result[index]
                                            ['o_p_l_n_s_id']),
                                        id: result[index]['id'],
                                        name: result[index]['Name'],
                                      ); 
                                      selectedProduct
                                          .selectedProduct(selectedproduct);

                                      print(selectedproduct.id);*/
                                          },
                                          child: (result.length == 0)
                                              ? Text("No Returns")
                                              : Card(
                                                  child: ListTile(
                                                    title: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          (result[index][
                                                                      'customerName'] !=
                                                                  null)
                                                              ? Text(
                                                                  " Customer Name :${result[index]['customerName']}")
                                                              : Text(''),
                                                          (result[index][
                                                                      'customerName'] !=
                                                                  null)
                                                              ? Text(
                                                                  " Phone :${result[index]['customerPhone']}")
                                                              : Text(''),
                                                          Text(
                                                            "${result[index]['product']['Name']}",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    subtitle: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  "Qty: ${result[index]['Quantity'].toString()}",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              SizedBox(
                                                                width: 20.0,
                                                              ),
                                                              Text(
                                                                "Price: ${formatnum.format(result[index]['Price']).toString()}",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    trailing: Text(
                                                      "Ksh: ${formatnum.format(result[index]['LineTotal']).toString()}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                );
                        } else if (snapshot.hasError) {
                          return Text('');
                        }

                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }),
                ),
              ),
              FutureBuilder<int>(
                  future: datapayment,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.hasData);
                      var result = snapshot.data!;

                      return Text(
                        ('Total Sales : ${formatnum.format(result)}'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
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
