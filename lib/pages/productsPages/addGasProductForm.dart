import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/itm4.dart';
import 'package:testproject/models/postSale.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';

enum GasSellTypeEnum { Refill, Full }

class AddGasProductForm extends StatefulWidget {
  @override
  State<AddGasProductForm> createState() => _AddGasProductFormState();
}

class _AddGasProductFormState extends State<AddGasProductForm> {
  final _formKey = GlobalKey<FormState>();
  int _qtyToSell = 1;
  double _sellingPrice = 0;
  double _total = 0;
  String _productName = "";
  int _linenum = 0;
  List priceListsNames = [];
  String? ref1;
  Map<String, dynamic> _generalSettingDetails = {};

  GasSellTypeEnum? _gasSellTypeEnum;
  int gasPrice = 0;
  String gasType = '';
  var _dropDownValue;

  @override
  void initState() {
    _generalSettingDetails = context.read<GetProducts>().generalSettingsDetails;

    super.initState();
  }

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

    final sellingGasPrice =
        context.watch<ProductListProvider>().selectedGasPrice;
    /* for (var i = 0; i < _selectedProd['itm4'].length; i++) {
      priceListsNames.add(_selectedProd['itm4'][i]['Name']);
    }
    print('Price Lists Names $priceListsNames'); */
    List itm4list = _selectedProd["itm4"];
    final previousrouteString = productsData.previousRoute;
    TextEditingController controllerText;
    //print(_selectedProd['itm4']);
    // for (var i; _selectedProd["itm4"]; i++) {
    //   itm4list.add(i);
    // }
    // print('93859358384586934756347867346789347869734867834 $itm4list');

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Text("Add Gas",
                    style: TextStyle(
                      fontSize: 20.0,
                    )),
                /*  (previousrouteString == '/customercreditnotereplacement')
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
                          ), */

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
                            validator: (val) => val!.isEmpty
                                ? 'Please Enter Product Name'
                                : null,
                            onChanged: (val) => setState(() {
                              _productName = _selectedProd['Name'];
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: RadioListTile<GasSellTypeEnum>(
                            value: GasSellTypeEnum.Refill,
                            groupValue: _gasSellTypeEnum,
                            title: Text(GasSellTypeEnum.Refill.name),
                            onChanged: (val) {
                              setState(() {
                                _gasSellTypeEnum = val;
                                gasType = val!.name;
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
                                gasType = val!.name;
                              });
                            }))
                  ],
                ),

                Consumer<ProductListProvider>(
                  builder: (context, value, child) {
                    return (_generalSettingDetails['enablePriceList'] == 'Y')
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
                                child: Consumer<ProductListProvider>(
                                  builder: (context, value, child) {
                                    return DropdownButton(
                                      hint: _dropDownValue == null
                                          ? Text('Price List')
                                          : Text(
                                              _dropDownValue,
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                      isExpanded: true,
                                      iconSize: 30.0,
                                      style: TextStyle(color: Colors.blue),
                                      items: itm4list.map(
                                        (val) {
                                          return DropdownMenuItem(
                                            value: val['pricelist']['Name'],
                                            child:
                                                Text(val['pricelist']['Name']),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (val) {
                                        var existingItm4 = itm4list.firstWhere(
                                            (itemToCheck) =>
                                                itemToCheck['pricelist']
                                                    ['Name'] ==
                                                val);
                                        if (gasType == 'Refill') {
                                          gasPrice = existingItm4['refill'];

                                          setState(() {
                                            _sellingPrice = gasPrice.toDouble();
                                          });
                                          value.setselectededGasPrice(
                                              gasPrice.toDouble());
                                        } else if (gasType == 'Full') {
                                          gasPrice = existingItm4['fullGas'];
                                          setState(() {
                                            _sellingPrice = gasPrice.toDouble();
                                          });
                                          value.setselectededGasPrice(
                                              gasPrice.toDouble());
                                          /*  final _sellingPrice =
                                              value.setselectededGasPrice(
                                                  gasPrice.toDouble());
                                          print(_sellingPrice); */
                                        } else {
                                          final _sellingPrice =
                                              value.setselectededGasPrice(
                                                  gasPrice.toDouble());
                                          print(_sellingPrice);
                                        }

                                        setState(
                                          () {
                                            _dropDownValue = val;
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          initialValue: _qtyToSell.toString(),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'Qty To Sell',
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 1.0),
                                            ),
                                          ),
                                          validator: (val) => val!.isEmpty
                                              ? 'Please Enter Qty to Sell'
                                              : null,
                                          onChanged: (val) => setState(() {
                                            _qtyToSell = int.parse(
                                              val,
                                            );
                                            _total = _qtyToSell * _sellingPrice;
                                          }),
                                        ),
                                      ),
                                    ),
                                    Consumer<ProductListProvider>(
                                      builder: (context, value, child) {
                                        print(
                                            '############################################ selling Price $_sellingPrice');
                                        final initialSelingPrice =
                                            _sellingPrice.toString();

                                        /* print(
                                            'Selellllllllllllllllllllllllllllllllll ${value.selectedGasPrice}'); */
                                        return Expanded(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                /*  key: Key(initialSelingPrice), */
                                                key: Key(
                                                    (value.selectedGasPrice)
                                                        .toString()),
                                                initialValue: value
                                                    .selectedGasPrice
                                                    .toString(),
                                                /*  (value
                                                        .selectedGasPrice
                                                        .toInt())
                                                    .toString() */
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                decoration: InputDecoration(
                                                  labelText: 'Selling Price',
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.red,
                                                        width: 1.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue,
                                                        width: 1.0),
                                                  ),
                                                ),
                                                validator: (val) {
                                                  setState(() {
                                                    _sellingPrice =
                                                        double.parse((val!));
                                                    _total = _qtyToSell *
                                                        _sellingPrice;
                                                  });
                                                },
                                                onEditingComplete: () {},
                                                onChanged: (val) {
                                                  setState(() {
                                                    _sellingPrice =
                                                        double.parse((val));
                                                  });

                                                  /*  value.setselectededGasPrice(
                                                      _sellingPrice);
                                                  _total = _qtyToSell *
                                                      value.selectedGasPrice; */
                                                },
                                              )),
                                        );
                                      },
                                    ),
                                  ]),
                              /* (previousrouteString == '/gassale')
                                  ? Card(
                                      child:
                                          Text('Total: ${_total.toString()}'),
                                    )
                                  : Text(''), */
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          initialValue: _qtyToSell.toString(),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'Qty To Sell',
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 1.0),
                                            ),
                                          ),
                                          validator: (val) => val!.isEmpty
                                              ? 'Please Enter Qty to Sell'
                                              : null,
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
                                        child: Consumer<ProductListProvider>(
                                          builder: (context, value, child) {
                                            return TextFormField(
                                              initialValue:
                                                  _sellingPrice.toString(),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              decoration: InputDecoration(
                                                labelText: 'Selling Price',
                                                fillColor: Colors.white,
                                                filled: true,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue,
                                                      width: 1.0),
                                                ),
                                              ),
                                              validator: (val) {
                                                setState(() {
                                                  _sellingPrice =
                                                      double.parse((val!));
                                                  _total = _qtyToSell *
                                                      _sellingPrice;
                                                });
                                              },
                                              onChanged: (val) => setState(() {
                                                _sellingPrice =
                                                    double.parse((val));
                                                _total =
                                                    _qtyToSell * _sellingPrice;
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ]),
                            ],
                          );
                  },
                ),

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
                (previousrouteString != '/gassale')
                    ? Card(
                        child: Text('Total: ${_total.toString()}'),
                      )
                    : Text(''),
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
                          gasType: gasType,
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

                        productsData.addGasProduct(newproduct);
                        Navigator.pushNamed(context, '/gassale');
                      }
                    },
                  ),
                )
              ],
            ),
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
