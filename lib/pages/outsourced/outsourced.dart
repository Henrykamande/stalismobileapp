import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/outsourcedModel.dart';
import 'package:testproject/models/product.dart';
import 'package:testproject/providers/productslist_provider.dart';

class OutsourcedProducts extends StatefulWidget {
  @override
  State<OutsourcedProducts> createState() => _OutsourcedProducts();
}

class _OutsourcedProducts extends State<OutsourcedProducts> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  int _qtyToSell = 1;
  double _sellingPrice = 0;
  double _total = 0;
  double _buyPrice = 0;

  /* double _totalPrice() {Products
    setState(() {
      _total = _qtyToSell * _sellingPrice;
    });
    return _total;
  } */

  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);
    final products = productsData.productlist;

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Add Outsourced',
                style: TextStyle(fontSize: 20.0),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '',
                        decoration: InputDecoration(
                          hintText: "Enter Product Name",
                          labelText: 'Product Name',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.white,
                            width: 3.0,
                          )),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Please Enter Product Name' : null,
                        onChanged: (val) => setState(() => _productName = val),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: _qtyToSell.toString(),
                        decoration: InputDecoration(
                          labelText: 'Qty To Sell',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          )),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Please Enter Product Name' : null,
                        onChanged: (val) => setState(() {
                          _qtyToSell = int.parse(
                            val,
                          );
                          _total = _qtyToSell * _sellingPrice;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Buying Price',
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
                    validator: (val) =>
                        val!.isEmpty ? 'Please Enter Quaitity ' : null,
                    onChanged: (val) => setState(() {
                      _buyPrice = double.parse(val);
                    }),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Selling Price',
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
                    validator: (val) =>
                        val!.isEmpty ? 'Please Enter Quaitity ' : null,
                    onChanged: (val) => setState(() {
                      _sellingPrice = double.parse(val);
                      _total = _qtyToSell * _sellingPrice;
                    }),
                  ),
                ),
              ]),

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
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final outsourcedProduct = new OutSourcedProducts(
                      productName: _productName,
                      quantity: _qtyToSell,
                      buyingPrice: _buyPrice,
                      sellingPrice: _sellingPrice,
                      totalAmount: _total,
                    );

                    /* final newproduct = new ResponseDatum(
                      sellingPrice: result[index]['sellingPrice'],
                      availableQty: result[index]['availableQty'],
                      o_p_l_n_s_id: result[index]['o_p_l_n_s_id'],
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: _productName, */

                    productsData.addProduct(outsourcedProduct);
                    Navigator.pop(context, outsourcedProduct);
                  }
                },
              )
            ],
          ),
        ));
  }
}
