import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import '../productsPages/addProductForm.dart';

class PaymentSearch extends StatefulWidget {
  @override
  _PaymentSearchState createState() => _PaymentSearchState();
}

class _PaymentSearchState extends State<PaymentSearch> {
  final _formKey = GlobalKey<FormState>();
  String _paymentAmount = '';
  String _paymentMode = '';
  String _searchquery = "";
  late TextEditingController amountPaid;
  late TextEditingController selectedAccountName;
  var _isLoading = false;

  var accounts = [];
  // GetProducts _accountslistbulder = GetProducts();

  void fetchAccounts() async {
    setState(() {
      _isLoading = true;
    });
    final response = await httpGet('bank-accounts');
    final accountsResponse = jsonDecode(response.body);

    if(accountsResponse['ResultCode'] == 1200) {
      setState(() {
        accounts = accountsResponse['ResponseData'];
      });
    }

    setState(() {
      _isLoading = false;
    });

  }

  void initState() {
    super.initState();
    fetchAccounts();
    //amountPaid = TextEditingController();
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
  Widget build(BuildContext context) {
    final paymentsData = Provider.of<ProductListProvider>(context);
    final previousrouteString = paymentsData.previousRoute;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Container(
          child: Text('Add Payment'),
        ),
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: true,
      body: _isLoading == true ? Center(child: CircularProgressIndicator())  : SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () async {
                        Payment selectedAccount = new Payment(
                          oACTSId: accounts[index]['id'],
                          name: accounts[index]['Name'],
                        );

                        /*  openAddPaymentDialog(paymentsData,
                                    selectedAccount, previousrouteString);
 */

                        await paymentsData
                            .accountchoice(selectedAccount);
                        _showaddPaymentPane();
                      },
                      child: ListTile(
                        title: Text(accounts[index]['Name']),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
