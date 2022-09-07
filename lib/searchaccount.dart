import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/accountmodel.dart';
import 'package:testproject/models/creditmemo.dart';
import 'package:testproject/models/paymentsAccounts.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/models/product.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'addProductForm.dart';

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

  late Future<List<dynamic>> accountsList;
  GetProducts _accountslistbulder = GetProducts();

  void initState() {
    super.initState();
    accountsList = _accountslistbulder.getaccounts(_searchquery);
    amountPaid = TextEditingController();
  }

  void _showaddProductPane() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: AddProductForm(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsData = Provider.of<ProductListProvider>(context);
    final previousrouteString = paymentsData.previousRoute;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text('Add Payment'),
        ),
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (val) => setState(() => _searchquery = val),
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
                child: FutureBuilder<List<dynamic>>(
                    future: accountsList,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {}
                      if (snapshot.hasData) {
                        List<dynamic> result = snapshot.data!;
                        print(result);
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: result.length,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              Payment selectedAccount = new Payment(
                                oACTSId: result[index]['id'],
                                name: result[index]['Name'],
                              );
                              openAddPaymentDialog(paymentsData,
                                  selectedAccount, previousrouteString);

                              paymentsData.accountSelected(selectedAccount);
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
    );
  }

  Future openAddPaymentDialog(
      paymentsData, selectedAccout, previousrouteString) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payment'),
        content: Container(
          height: 100,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                initialValue: selectedAccout.name,
              ),
              TextField(
                controller: amountPaid,
                decoration: InputDecoration(hintText: "Enter Amount Paid "),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (previousrouteString == '/customercreditnote') {
                Navigator.pushNamed(context, '/start');
              }
              if (previousrouteString == '/customerDeposit') {
                Navigator.pushNamed(context, '/customerDeposit');
              }
              if (previousrouteString == '/start') {
                submit(paymentsData, selectedAccout, previousrouteString);
                Navigator.pushNamed(context, '/start');
              }
            },
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              submit(paymentsData, selectedAccout, previousrouteString);
            },
            child: Text('Add Payment'),
          ),
        ],
      ),
    );
  }

  void submit(paymentData, selectedAccount, previousrouteString) {
    Payment newpayment = Payment(
        sumApplied: int.parse(amountPaid.text),
        oACTSId: selectedAccount.oACTSId,
        name: selectedAccount.name);

    if (previousrouteString == '/customercreditnote') {
      TopupPayment newpayment = new TopupPayment(
        paymentMode: selectedAccount.name,
        SumApplied: int.parse(amountPaid.text),
        o_a_c_t_s_id: selectedAccount.oACTSId,
      );
      paymentData.addTopUpPayment(newpayment);
      Navigator.pushNamed(context, '/customercreditnote');
    }

    if (previousrouteString == '/customerDeposit') {
      paymentData.addDepositPayment(newpayment);
      Navigator.pushNamed(context, '/customerDeposit');
    }
    if (previousrouteString == '/start') {
      paymentData.addPayment(newpayment);
      Navigator.pushNamed(context, '/start');
    }
  }
}
