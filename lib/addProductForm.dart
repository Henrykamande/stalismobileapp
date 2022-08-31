import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/models/product.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';

class AddProductForm extends StatefulWidget {
  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  int _qtyToSell = 1;
  int _sellingPrice = 0;
  int _total = 0;
  String _productName = "";
  int _linenum = 0;
  String? ref1;

  /* double _totalPrice() {Products
    setState(() {
      _total = _qtyToSell * _sellingPrice;
    });
    return _total;
  } */

  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);
    final selectedProdp = Provider.of<GetProducts>(context);
    final _selectedProd = selectedProdp.selectedprod;
    print(_selectedProd.name);
    final products = productsData.productlist;
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Add a Product',
                style: TextStyle(fontSize: 20.0),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: _selectedProd.name,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Enter Product Name",
                            labelText: 'Product Name',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Please Enter Product Name' : null,
                          onChanged: (val) => setState(() {
                            _productName = _selectedProd.name;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: _qtyToSell.toString(),
                      decoration: InputDecoration(
                        labelText: 'Qty To Sell',
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 1.0),
                        ),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Please Enter Qty to Sell' : null,
                      onChanged: (val) => setState(() {
                        _qtyToSell = int.parse(
                          val,
                        );
                        _total = _qtyToSell * _sellingPrice;
                      }),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Selling Price',
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 1.0),
                        ),
                      ),
                      validator: (val) {
                        setState(() {
                          _sellingPrice = int.parse((val!));
                          _total = _qtyToSell * _sellingPrice;
                        });
                      },
                      onChanged: (val) => setState(() {
                        _sellingPrice = int.parse((val));
                        _total = _qtyToSell * _sellingPrice;
                      }),
                    ),
                  ),
                ),
                /* Expanded(
                  child: TextFormField(
                    initialValue: _selectedProd.availableQty.toString(),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Available',
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      )),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.pink,
                        width: 2.0,
                      )),
                    ),
                  ),
                ), */
              ]),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter Ref/Serial No",
                    labelText: 'Ref/Serial No',
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please Ref/Serial No' : null,
                  onChanged: (val) => setState(() {
                    ref1 = val;
                  }),
                ),
              ),

              Card(
                child: Text('Total: $_total'),
              ),
              SizedBox(
                height: 20.0,
              ),
              //Dropdown

              RaisedButton(
                color: Colors.pink[400],
                child: Text(
                  'Add To List',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (productsData.productlist.length == 0) {
                      setState(() {
                        _linenum = 0;
                      });
                    } else {
                      _linenum = productsData.productlist.length + 1;
                    }

                    final newproduct = new SaleRow(
                      ref1: ref1,
                      name: _selectedProd.name,
                      oPLNSId: _selectedProd.o_p_l_n_s_id,
                      sellingPrice: _sellingPrice,
                      quantity: _qtyToSell,
                      oITMSId: _selectedProd.id,
                      lineTotal: _total,
                      lineNum: _linenum,
                      discSum: 0,
                      commission: 0,
                      taxId: null,
                      taxRate: null,
                      taxAmount: null,
                    );
                    productsData.addProduct(newproduct);
                    Navigator.pushNamed(context, '/start');
                  }
                },
              )
            ],
          ),
        ));
  }

  snackbarmessage() {
    final snackBar = SnackBar(
      content: const Text('Hi, I am a SnackBar!'),
      backgroundColor: (Colors.black12),
      action: SnackBarAction(
        label: 'dismiss',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
