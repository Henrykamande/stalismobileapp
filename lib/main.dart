import 'package:flutter/material.dart';
import 'package:testproject/creditnote.dart';
import 'package:testproject/deposit.dart';
import 'package:testproject/paymentslist.dart';
import 'package:testproject/providers/defaultprinter.dart';
import 'package:testproject/retrunedProducts.dart';
import 'package:testproject/searchaccount.dart';
import 'package:testproject/addProductForm.dart';
import 'package:testproject/inventorylist.dart';
import 'package:testproject/loginPage.dart';
import 'package:testproject/print_page.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/login_service.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/searchproduct.dart';
import 'package:testproject/soldProducts.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';
import 'package:testproject/providers/productslist_provider.dart';

void main() => runApp(Stalisapp());

class Stalisapp extends StatelessWidget {
  const Stalisapp({Key? key}) : super(key: key);
  static const String title = "Stalis Pos";
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (cxt) => ProductListProvider(),
        ),
        ChangeNotifierProvider(
          create: (cxt) => GetProducts(),
        ),
        ChangeNotifierProvider(
          create: (cxt) => UserLogin(),
        ),
        ChangeNotifierProvider(
          create: (cxt) => DefaultPrinter(),
        )
      ],
      child: MaterialApp(
          initialRoute: '/',
          routes: {
            '/login': (context) => LoginPage(),
            '/start': (context) => HomePage(),
            '/searchproduct': (context) => SearchProduct(),
            '/inventory': (context) => InventoryList(),
            '/soldproducts': (context) => SoldProducts(),
            '/paymentsearch': (context) => PaymentSearch(),
            '/salepayments': (context) => SalePayment(),
            '/defaultprinter': (context) => PrintPage(),
            '/customerDeposit': (context) => CustomerDeposit(),
            '/customercreditnote': (context) => CustomerCreditNote(),
            '/returnedproducts': (context) => ReturnProducts(),
          },
          title: title,
          home: Scaffold(
              appBar: AppBar(
                title: Text(title),
              ),
              body: LoginPage() //LoginPage()
              )),
    );
  }
}
