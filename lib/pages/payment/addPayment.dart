import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/depositPayment.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/models/previousRoute.dart';
import 'package:testproject/models/product.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';

class AddPaymentForm extends StatefulWidget {
  @override
  State<AddPaymentForm> createState() => _AddPaymentFormState();
}

class _AddPaymentFormState extends State<AddPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  int _amountPaid = 0;
  String _accountName = "";
  String ref1 = "";
  String remarks = '';

  /* double _totalPrice() {Products
    setState(() {
      _total = _qtyToSell * _sellingPrice;
    });
    return _total;
  } */

  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);

    final previousrouteString = productsData.previousRoute;
    final accountSelected = productsData.accountSelected ?? "";

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
                          'Add Top Up Payment',
                          style: TextStyle(fontSize: 20.0),
                        )
                      : Text(
                          'Add Payment',
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
                          initialValue: accountSelected.name ?? "",
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Account Name",
                            labelText: 'Account Name',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Please Enter Acount Name' : null,
                          onChanged: (val) => setState(() {
                            _accountName = accountSelected.name;
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
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount Paid',
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
                      onChanged: (val) => setState(() {
                        _amountPaid = int.parse((val));
                      }),
                    ),
                  ),
                ),
              ]),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Remarks',
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
                        onChanged: (val) => setState(() {
                              remarks = val;
                            })),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              //Dropdown

              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: (previousrouteString == '/customercreditnote')
                      ? Text(
                          'Add Top Up Payment',
                          style: TextStyle(color: Colors.white),
                        )
                      : (previousrouteString == '/customerDeposit')
                          ? Text(
                              'Add Deposit Payment',
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              'Add Payment',
                              style: TextStyle(color: Colors.white),
                            ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Payment newpayment = Payment(
                        sumApplied: _amountPaid,
                        oACTSId: accountSelected.oACTSId,
                        name: accountSelected.name,
                        paymentRemarks: remarks,
                      );

                      if (previousrouteString == '/customercreditnote') {
                        TopupPayment topnewpayment = new TopupPayment(
                          paymentMode: accountSelected.name,
                          SumApplied: _amountPaid,
                          o_a_c_t_s_id: accountSelected.oACTSId,
                          paymentRemarks: remarks,
                        );
                        productsData.addTopUpPayment(topnewpayment);
                        Navigator.pushNamed(context, '/customercreditnote');
                      }

                      if (previousrouteString == '/customerDeposit') {
                        productsData.addDepositPayment(newpayment);
                        Navigator.pushNamed(context, '/customerDeposit');
                      }
                      if (previousrouteString == '/customerdepositlist') {
                        if (_amountPaid >
                            productsData.selecteddepositItem['Balance']) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                  'Payment Should not be more than Balance')));
                          Navigator.pushNamedAndRemoveUntil(context,
                              '/customerdepositlist', (route) => false);
                        } else {
                          PaymentList newpayment = new PaymentList(
                              oACTSId: accountSelected.oACTSId,
                              sumApplied: _amountPaid,
                              paymentRemarks: remarks);
                          // ScaffoldMessenger.of(context).showSnackBar();
                          final depositPayment = DepositPayment(
                              odlnId: productsData.selecteddepositItem['id'],
                              docDate: DateTime.now(),
                              totalPaid:
                                  productsData.selecteddepositItem['PaidSum'],
                              payments: [newpayment]);
                          context
                              .read<GetProducts>()
                              .postDepositPayment(depositPayment);
                          Navigator.pushNamed(
                            context,
                            '/customerdepositlist',
                          );
                        }
                      }
                      if (previousrouteString == '/start') {
                        productsData.addPayment(newpayment);
                        Navigator.pushNamed(context, '/start');
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}
