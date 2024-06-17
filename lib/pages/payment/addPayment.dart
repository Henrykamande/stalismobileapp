import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/postSale.dart';
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

  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);

    // final previousrouteString = productsData.previousRoute;
    final accountSelected = productsData.accountSelected ?? "";

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
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
                            validator: (val) => val!.isEmpty
                                ? 'Please Enter Acount Name'
                                : null,
                            onChanged: (val) => setState(() {
                              _accountName = accountSelected.name;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.0),
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
                            labelText: 'Ref No',
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
                    child: Text(
                      'Add Payment',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Payment newPayment = Payment(
                          sumApplied: _amountPaid,
                          accountId: accountSelected.accountId,
                          // name: accountSelected.name,
                          paymentRemarks: remarks,
                        );

                        productsData.addPayment(newPayment);
                        Navigator.pushNamed(context, '/start');

                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
