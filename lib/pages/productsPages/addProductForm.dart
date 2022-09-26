import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/postSale.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';

enum GasSellTypeEnum { Refill, Full }

class AddProductForm extends StatefulWidget {
  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  int _qtyToSell = 1;
  double _sellingPrice = 0;
  double _total = 0;
  String _productName = "";
  int _linenum = 0;
  String? ref1;
  GasSellTypeEnum? _gasSellTypeEnum;
  var _dropDownValue;

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

    final previousrouteString = productsData.previousRoute;
    final products = productsData.productlist;

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              (previousrouteString == '/customercreditnotereplacement')
                  ? Text(
                      'Add Replacement',
                      style: TextStyle(fontSize: 20.0),
                    )
                  : (previousrouteString == '/customercreditnote')
                      ? Text(
                          'Add Return Product',
                          style: TextStyle(fontSize: 20.0),
                        )
                      : Text(
                          'Add Product',
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
                          initialValue: _selectedProd['Name'],
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
                            _productName = _selectedProd['Name'];
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              (previousrouteString == '/gassale')
                  ? Row(
                      children: [
                        Expanded(
                            child: RadioListTile<GasSellTypeEnum>(
                                value: GasSellTypeEnum.Refill,
                                groupValue: _gasSellTypeEnum,
                                title: Text(GasSellTypeEnum.Refill.name),
                                onChanged: (val) {
                                  setState(() {
                                    _gasSellTypeEnum = val;
                                  });
                                })),
                        Expanded(
                            child: RadioListTile<GasSellTypeEnum>(
                                value: GasSellTypeEnum.Full,
                                groupValue: _gasSellTypeEnum,
                                title: Text(GasSellTypeEnum.Full.name),
                                onChanged: (val) {
                                  setState(() {
                                    _gasSellTypeEnum = val;
                                  });
                                }))
                      ],
                    )
                  : Text(''),
              Consumer<ProductListProvider>(
                builder: (context, value, child) {
                  return (value.multiplePriceList == true)
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [Text('Select Price List')],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButton(
                                hint: _dropDownValue == null
                                    ? Text('Price List')
                                    : Text(
                                        _dropDownValue,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                isExpanded: true,
                                iconSize: 30.0,
                                style: TextStyle(color: Colors.blue),
                                items: ['Retail', 'WholeSale'].map(
                                  (val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: Text(val),
                                    );
                                  },
                                ).toList(),
                                onChanged: (val) {
                                  setState(
                                    () {
                                      _dropDownValue = val;
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : Text('');
                },
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: _qtyToSell.toString(),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                          _sellingPrice = double.parse((val!));
                          _total = _qtyToSell * _sellingPrice;
                        });
                      },
                      onChanged: (val) => setState(() {
                        _sellingPrice = double.parse((val));
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

              (previousrouteString == '/gassale')
                  ? Text('')
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter Ref/Serial No",
                          labelText: 'Ref/Serial No',
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 1.0),
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
                child: Text('Total: ${_total.toString()}'),
              ),
              SizedBox(
                height: 20.0,
              ),
              //Dropdown

              Container(
                width: double.infinity,
                child: ElevatedButton(
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
                        name: _selectedProd['Name'],
                        oPLNSId: _selectedProd['o_p_l_n_s_id'],
                        sellingPrice: _sellingPrice,
                        quantity: _qtyToSell,
                        oITMSId: _selectedProd['id'],
                        lineTotal: _total,
                        lineNum: _linenum,
                        discSum: 0,
                        commission: 0,
                        taxId: null,
                        taxRate: null,
                        taxAmount: null,
                      );
                      if (previousrouteString ==
                          '/customercreditnotereplacement') {
                        ReplacedProduct newproduct = new ReplacedProduct(
                          productName: _selectedProd['Name'],
                          productId: _selectedProd['id'],
                          quantity: _qtyToSell,
                          sellingPrice: _sellingPrice,
                          lineTotal: _total,
                          ref1: ref1,
                        );
                        productsData.addReplacementProduct(newproduct);
                        Navigator.pushNamed(context, '/customercreditnote');
                      } else {}
                      if (previousrouteString == '/customercreditnote') {
                        ReturnedProduct newproduct = new ReturnedProduct(
                          productName: _selectedProd['Name'],
                          productId: _selectedProd['id'],
                          quantity: _qtyToSell,
                          sellingPrice: _sellingPrice,
                          lineTotal: _total,
                          ref1: ref1,
                        );
                        productsData.addReturnProduct(newproduct);
                        Navigator.pushNamed(context, '/customercreditnote');
                      } else {}
                      if (previousrouteString == '/customerDeposit') {
                        productsData.addDepositProduct(newproduct);
                        Navigator.pushNamed(context, '/customerDeposit');
                      } else {}
                      if (previousrouteString == '/start') {
                        productsData.addProduct(newproduct);
                        Navigator.pushNamed(context, '/start');
                      } else {}

                      if (previousrouteString == '/gassale') {
                        productsData.addProduct(newproduct);

                        Navigator.pushNamed(context, '/gassale');
                      }
                    }
                  },
                ),
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
