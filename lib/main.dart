import 'dart:io';

import 'package:flutter/material.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';
import 'package:testproject/pages/Transfer/transfer_screen.dart';
import 'package:testproject/pages/accounts.dart';
import 'package:testproject/pages/creditmemo/creditnote.dart';
import 'package:testproject/pages/customers.dart';
import 'package:testproject/pages/data_sync.dart';
import 'package:testproject/pages/deposit/deposit.dart';
import 'package:testproject/pages/deposit/listdeposits.dart';
import 'package:testproject/pages/gassale/gasSale.dart';
import 'package:testproject/pages/login/loginPage.dart';
import 'package:testproject/pages/payment/paymentslist.dart';
import 'package:testproject/pages/products_list.dart';
import 'package:testproject/providers/accounts.dart';
import 'package:testproject/providers/customer.dart';
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
import 'package:testproject/providers/products.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';
import 'package:testproject/providers/productslist_provider.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  runApp(Stalisapp());
}

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
          create: (cxt) => CustomerProvider(),
        ),
        ChangeNotifierProvider(
          create: (cxt) => AccountsProvider(),
        ),
        ChangeNotifierProvider(
          create: (cxt) => ProductsProvider(),
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
        // ChangeNotifierProvider(
        //   create: (cxt) => DatabaseHelper(),
        // )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          // initialRoute: DataSyncScreen.routeName,
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
            '/generalsettings': (context) => MyPrinter(),
            '/generalsettings': (context) => MyPrinter(),
            DataSyncScreen.routeName: (ctx) => const DataSyncScreen(),
            CustomersListScreen.routeName: (ctx) => const CustomersListScreen(),
            AccountsListScreen.routeName: (ctx) => const AccountsListScreen(),
            ProductsListScreen.routeName: (ctx) => const ProductsListScreen()
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
