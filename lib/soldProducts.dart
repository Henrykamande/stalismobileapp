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

  String _searchquery = "";
  GetProducts _listbulder = GetProducts();
  TextEditingController dateInput = TextEditingController();

  @override
  void initState() {
    _listbulder.fetchSoldProducts(_searchquery);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = Provider.of<GetProducts>(context);
    soldproducts = _listbulder.fetchSoldProducts(_searchquery);
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  height: 20.0,
                  child: TextField(
                      controller: dateInput,
                      //editing controller of this TextField
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Select Date" //label text of field
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
                        }
                      }),
                ),
              ),
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

                          return (_searchquery != '')
                              ? ListView.builder(
                                  itemCount: result.length,
                                  itemBuilder: (context, index) => InkWell(
                                    onTap: () {
                                      //print(result[index]['name']);

                                      final selectedproduct = new ResponseDatum(
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

                                      print(selectedproduct.id);
                                    },
                                    child: ListTile(
                                      title: Text(
                                          result[index]['Name'].toString()),
                                      subtitle: Text(
                                          "Selling Price: Ksh ${result[index]['SellingPrice'].toString()}"),
                                      trailing: Text(
                                          "Av.Qty:  ${result[index]['AvailableQty']..toString()}"),
                                    ),
                                  ),
                                )
                              : Text('Enter prouct to search');
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
