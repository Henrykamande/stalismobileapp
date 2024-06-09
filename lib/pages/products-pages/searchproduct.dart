import 'package:flutter/material.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';
import 'package:testproject/pages/payment/addPayment.dart';
import 'package:testproject/pages/products-pages/addGasProductForm.dart';
import 'package:testproject/pages/products-pages/addProductForm.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';

import 'package:testproject/providers/productslist_provider.dart';

class SearchProduct extends StatefulWidget {
  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  String? _searchProductTerm;
  late Future<List<dynamic>> productlistdata;

  String _searchquery = "";

  @override
  void initState() {
    // _todolistbulder.getTodoList(_searchquery);
    super.initState();
  }

  void _showaddProductPane() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: AddProductForm(),
          );
        });
  }

  void _gasaddProductPane() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: AddGasProductForm(),
          );
        });
  }

  @override
  void dispose() {
    // Close the database connection when the widget is disposed
    // DatabaseHelper.instance.database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Text(
          'Search Product',
          style: TextStyle(fontSize: 20.0),
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
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (val) {
                    setState(() {
                      _searchProductTerm = val;
                    });
                    _setSearchterm(val);
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.grey[400],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.purple.shade900,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                  child: Consumer<GetProducts>(
                    builder: (context, value, child) {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.instance
                            .searchProducts(_searchProductTerm),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Center(
                              child: Text("No data available."),
                            );
                          }

                          List<Map<String, dynamic>> result = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: result.length,
                            itemBuilder: (context, index) => InkWell(
                              onTap: () {
                                print(result);
                                value.selectedProduct(result[index]);
                                _showaddProductPane();
                              },
                              child: ListTile(
                                title: Text(result[index]['Name']),
                                subtitle: Text(
                                    "Selling Price: Ksh ${result[index]['SellingPrice']}"),
                                trailing: Text(
                                    "Av.Qty: ${result[index]['AvailableQty']}"),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setSearchterm(val) {
    setState(() {
      _searchquery = val;
    });
  }
}
