import 'package:flutter/material.dart';
import 'package:testproject/searchaccount.dart';
import 'package:testproject/main.dart';
import 'package:provider/provider.dart';
import 'package:testproject/models/postSale.dart';
import 'package:testproject/outsourced.dart';
import 'package:testproject/print_page.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/searchproduct.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PrefService _prefs = PrefService();
  var cache;
  TextEditingController dateInput = TextEditingController();
  String saleType = '';
  List<SaleRow> products = [];
  @override
  void initState() {
    products = [];
    super.initState();
  }

  /* void _showaddProductPane() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 60.0),
            child: AddProductForm(),
          );
        });
  }
 */
  /* void _searchPaymentPane() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: PaymentSearch(),
          );
        });
  } */

  void _showoutsourcedPane() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
            child: OutsourcedProducts(),
          );
        });
  }

  void _showsearchproductPane() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SearchProduct(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductListProvider>(context);

    final salepost = Provider.of<GetProducts>(context);
    List<SaleRow> products = productsData.productlist;
    //final paymentlist = productsData.paymentlist;
    final totalbill = productsData.totalPrice();
    final balance = productsData.balancepayment();
    final totalpayment = productsData.totalPaymentcalc();
    final List<Payment> paymentlist = productsData.paymentlist;

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade700,
          title: Center(
            child: Text(
              'Stalis Pos',
              style: TextStyle(),
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () async {
                cache = await _prefs.readCache(
                    'Token', 'StoreId', 'loggedInUserName');
                print(cache['Token']);
                await _prefs.removeCache(
                    'Token', 'StoreId', 'loggedInUserName');
                print(cache);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Stalisapp()));
              },
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
        /* persistentFooterButtons: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/searchproduct');
              },
              child: Text('Add Product')),
          TextButton(
              onPressed: _showaddPaymentPane, child: Text('Add Payment')),
          TextButton(
              onPressed: _showoutsourcedPane, child: Text('Add Outsourced')),
          TextButton(onPressed: () {}, child: Text('Save'))
        ], */
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Add Products',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: IconButton(
                      enableFeedback: false,
                      onPressed: () {
                        Navigator.pushNamed(context, '/searchproduct');
                      },
                      icon: const Icon(
                        Icons.widgets_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Add Payment',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: IconButton(
                      enableFeedback: false,
                      onPressed: () {
                        Navigator.pushNamed(context, '/paymentsearch');
                      },
                      icon: const Icon(
                        Icons.widgets_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Add Sourced',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: IconButton(
                      enableFeedback: false,
                      onPressed: _showoutsourcedPane,
                      icon: const Icon(
                        Icons.widgets_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        drawer: Container(
          child: Drawer(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 100,
                    child: DrawerHeader(
                      child: ListTile(
                        title: Text('Shop Name'),
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Text(''),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/start');
                          },
                          icon: Icon(Icons.cancel),
                        ),
                      ),
                      decoration: BoxDecoration(),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('POS'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pushNamed(context, '/start');
                  },
                ),
                ListTile(
                  title: const Text('Invetory'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pushNamed(context, '/inventory');
                  },
                ),
                ListTile(
                  title: const Text('Sold Products'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pushNamed(context, '/soldproducts');
                  },
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration:
                              InputDecoration(hintText: 'Customer Name'),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                            controller: dateInput,
                            //editing controller of this TextField
                            decoration: InputDecoration(
                                icon: Icon(
                                    Icons.calendar_today), //icon of text field
                                labelText: "Enter Date" //label text of field
                                ),
                            readOnly: true,
                            //set it true, so that user will not able to edit text
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime(2100));

                              if (pickedDate != null) {
                                print(
                                    pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                print(
                                    formattedDate); //formatted date output using intl package =>  2021-03-16
                                setState(() {
                                  dateInput.text =
                                      formattedDate; //set output date to TextField value.
                                });
                              }
                            }),
                      ),
                    ]),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) => index < products.length
                        ? Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(products[index].name.toString()),
                              subtitle: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Qty ${(products[index].quantity).toString()}",
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Price ${products[index].sellingPrice.toString()}",
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(products[index].lineTotal.toString()),
                                    Expanded(
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            productsData.removeProduct(index);
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Card(
                            child: Text("Hello"),
                          )),
              ),
              Container(
                height: 100.0,
                child: (paymentlist.length == 0)
                    ? Text("No payment added")
                    : ListView.builder(
                        itemCount: paymentlist.length,
                        itemBuilder: (context, index) =>
                            index < paymentlist.length
                                ? Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      title: Text('${paymentlist[index].name}'),
                                      trailing: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                                "Ksh ${(paymentlist[index].sumApplied).toString()}"),
                                            Expanded(
                                              child: IconButton(
                                                  icon: Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    productsData
                                                        .removePayment(index);
                                                  }),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Card(
                                    child: Text("Hello"),
                                  )),
              ),
              Container(
                decoration: new BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                          MediaQuery.of(context).size.width, 40.0)),
                ),
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: Ksh',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$totalbill',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment: Ksh',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$totalpayment',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance: Ksh',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$balance',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        RaisedButton(
                          onPressed: () async {
                            cache = await _prefs.readCache(
                                'Token', 'StoreId', 'loggedInUserName');
                            print(cache['loggedInUserName']);

                            if (balance > 0) {
                              setState(() {
                                saleType = 'credit';
                              });
                            }
                            if (balance == 0) {
                              setState(() {
                                saleType = 'cash';
                              });
                            }
                            print('payment List $paymentlist');
                            PosSale saleCard = new PosSale(
                                objType: 14,
                                docNum: 2,
                                discSum: 0,
                                cardCode: 1,
                                payments: paymentlist,
                                docTotal: totalbill,
                                balance: balance,
                                docDate: DateFormat('yyyy-MM-dd')
                                    .parse(dateInput.text),
                                rows: products,
                                totalPaid: totalpayment,
                                userName: cache['loggedInUserName']);

                            productsData.postsalearray(saleCard);

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PrintPage(saleCard)));
                            productsData.setprodLIstempty();
                          },
                          child: Text('Save'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
