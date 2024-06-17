import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';
import 'package:testproject/pages/payment/addPayment.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/models/accountmodel.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/paymentsAccounts.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/models/product.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';
import '../../utils/http.dart';
import '../products-pages/addProductForm.dart';

class PaymentSearch extends StatefulWidget {
  @override
  _PaymentSearchState createState() => _PaymentSearchState();
}

class _PaymentSearchState extends State<PaymentSearch> {
  late Future<List<dynamic>> accountsList;

  final _formKey = GlobalKey<FormState>();
  String _paymentAmount = '';
  String _paymentMode = '';
  String _searchquery = "";
  late TextEditingController amountPaid;
  late TextEditingController selectedAccountName;
  var _isLoading = false;

  void initState() {
    super.initState();
  }

  void _showaddPaymentPane() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: AddPaymentForm(),
          );
        });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    accountsList = DatabaseHelper.instance.getAllAccounts();
    final paymentsData = Provider.of<ProductListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Container(
          child: Text('Add Payment'),
        ),
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: true,
      body: _isLoading == true
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                      child: Container(
                        height: 300,
                        child: FutureBuilder<List<dynamic>>(
                            future: accountsList,
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {}
                              if (snapshot.hasData) {
                                List<dynamic> result = snapshot.data!;

                                return ListView.builder(
                                  itemCount: result.length,
                                  itemBuilder: (context, index) => InkWell(
                                    onTap: () async {
                                      Payment selectedAccount = new Payment(
                                        accountId: result[index]['id'],
                                        // name: result[index]['Name'],
                                      );

                                      await paymentsData.accountchoice(selectedAccount);
                                      _showaddPaymentPane();
                                    },
                                    child: ListTile(
                                      title: Text(result[index]['Name']),
                                    ),
                                  ),
                                );
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
