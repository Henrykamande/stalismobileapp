import 'package:flutter/material.dart';
import 'package:testproject/pages/payment/addPayment.dart';
import 'package:testproject/pages/productsPages/addGasProductForm.dart';
import 'package:testproject/pages/productsPages/addProductForm.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';

import 'package:testproject/providers/productslist_provider.dart';

class SearchProduct extends StatefulWidget {
  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
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
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);
    final previousrouteString = productsData.previousRoute;

    //print(_prefs.readCache('token','storeid'));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: (context.read<ProductListProvider>().previousRoute ==
                '/customercreditnotereplacement')
            ? Text(
                'Search Replacement Product',
                style: TextStyle(fontSize: 20.0),
              )
            : (context.read<ProductListProvider>().previousRoute ==
                    '/customercreditnote')
                ? Text(
                    'Search Return Product',
                    style: TextStyle(fontSize: 20.0),
                  )
                : Text(
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
                      return FutureBuilder<List<dynamic>>(
                          future: value.getProductsList(_searchquery),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {}
                            if (snapshot.hasData) {
                              List<dynamic> result = snapshot.data!;

                              return (_searchquery != '')
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: result.length,
                                      itemBuilder: (context, index) => InkWell(
                                        onTap: () {
                                          //print(result[index]['name']);

                                          /*   final selectedproduct = new ResponseDatum(
                                          name: result[index]['Name'],
                                          sellingPrice: double.parse(
                                              result[index]['SellingPrice']),
                                          id: result[index]['id'],
                                          availableQty: result[index]
                                              ['AvailableQty'],
                                          o_p_l_n_s_id: result[index]
                                              ['o_p_l_n_s_id'],
                                        );*/
                                          value.selectedProduct(result[index]);
                                          //_showaddProductPane();
                                          //print(selectedproduct.id);\
                                          if (previousrouteString ==
                                              '/gassale') {
                                            _gasaddProductPane();
                                          } else {
                                            _showaddProductPane();
                                          }
                                        },
                                        child: ListTile(
                                          title: Text(result[index]['Name']),
                                          subtitle: Text(
                                              "Selling Price: Ksh ${result[index]['SellingPrice'].toString()}"),
                                          /*trailing: Text(
                                            "Av.Qty:  ${result[index]['AvailableQty']..toString()}"), */
                                        ),
                                      ),
                                    )
                                  : Text('Enter product to search');
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }

                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          });
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
