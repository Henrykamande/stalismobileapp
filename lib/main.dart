import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testproject/pages/Transfer/transfer_screen.dart';
import 'package:testproject/pages/data_sync.dart';
import 'package:testproject/pages/login/loginPage.dart';
import 'package:testproject/pages/masterdata/accounts.dart';
import 'package:testproject/pages/masterdata/customers.dart';
import 'package:testproject/pages/masterdata/products_list.dart';
import 'package:testproject/pages/payment/searchaccount.dart';
import 'package:testproject/pages/printer-pages/printer-setup.dart';
import 'package:testproject/pages/products-pages/inventorylist.dart';
import 'package:testproject/pages/products-pages/searchproduct.dart';
import 'package:testproject/pages/sales/invoices.dart';
import 'package:testproject/pages/sales/paymentslist.dart';
import 'package:testproject/pages/sales/soldProducts.dart';
import 'package:testproject/providers/accounts.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/defaultprinter.dart';
import 'package:testproject/providers/login_service.dart';
import 'package:testproject/providers/printservice.dart';
import 'package:testproject/providers/productslist_provider.dart';

import './providers/customer.dart';

import './providers/products.dart';

import './utils/sync_service.dart';
import 'databasesql/sql_database_connection.dart';
import 'homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    FocusScope(
      autofocus: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: SyncService(),
          ),
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
          // ChangeNotifierProvider(
          //   create: (cxt) => PrinterService(),
          // ),
          // ChangeNotifierProvider(
          //   create: (cxt) => DatabaseHelper(),
          // )
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> subscription;

  var _syncingAll = false;

  Future<void> syncSales() async {
    await DatabaseHelper.instance.syncSales();
  }

  @override
  void initState() {
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        Provider.of<SyncService>(context, listen: false)
            .updateConnectionStatus(result);

        if (result == ConnectivityResult.wifi) {
          Timer.periodic(Duration(minutes: 2), (Timer t) {
            syncSales();
          });
        }
      },
    );
  }

  @override
  void dispose() {
  //  subscription.cancel();
    super.dispose();
  }

  // final auth = Auth();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stalispos',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
              .copyWith(secondary: Colors.pink[500])),
      // home: auth.isAuth ? const LandingScreen() : const LoginScreen(),
      home: Scaffold(
          appBar: AppBar(
            title: Text("Stalis Pos"),
          ),
          body: HomePage()
          ),
      routes: {
        LoginPage.routeName: (ctx) => LoginPage(),
        '/start': (context) => HomePage(),
        '/searchproduct': (context) => SearchProduct(),
        '/inventory': (context) => InventoryList(),
        '/soldproducts': (context) => SoldProducts(),
        '/paymentsearch': (context) => PaymentSearch(),
        '/salepayments': (context) => SalePayment(),
        '/transfer': (context) => TransferScreen(),
        PrinterSetupScreen.routeName: (ctx) => const PrinterSetupScreen(),
        DataSyncScreen.routeName: (ctx) => const DataSyncScreen(),
        CustomersListScreen.routeName: (ctx) => const CustomersListScreen(),
        AccountsListScreen.routeName: (ctx) => const AccountsListScreen(),
        ProductsListScreen.routeName: (ctx) => const ProductsListScreen(),
        InvoicesScreen.routeName: (ctx) => const InvoicesScreen()
      },
    );
  }
}
