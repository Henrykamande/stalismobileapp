import 'package:flutter/material.dart';
import 'package:testproject/pages/Transfer/transfer_screen.dart';
import 'package:testproject/pages/creditmemo/creditnote.dart';
import 'package:testproject/pages/deposit/deposit.dart';
import 'package:testproject/pages/deposit/listdeposits.dart';
import 'package:testproject/pages/gassale/gasSale.dart';
import 'package:testproject/pages/login/loginPage.dart';
import 'package:testproject/pages/payment/paymentslist.dart';
import 'package:testproject/providers/defaultprinter.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/pages/creditmemo/retrunedProducts.dart';
import 'package:testproject/pages/payment/searchaccount.dart';
import 'package:testproject/pages/productsPages/inventorylist.dart';

import 'package:testproject/pages/printerPages/general_settings.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/login_service.dart';
import 'package:testproject/pages/productsPages/searchproduct.dart';
import 'package:testproject/pages/productsPages/soldProducts.dart';
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
        ),
        ChangeNotifierProvider(
          create: (cxt) => PrinterService(),
        ),
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
            '/customerDeposit': (context) => CustomerDeposit(),
            '/customercreditnote': (context) => CustomerCreditNote(),
            '/returnedproducts': (context) => ReturnProducts(),
            '/gassale': (context) => GasSale(),
            '/customerdepositlist': (context) => CustomerDepositsList(),
            '/transfer': (context) => TransferScreen(),
            //'/generalsettings': (context) => MyPrinter(),
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
