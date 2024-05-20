import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:testproject/models/SyncPayment.dart';
import 'package:testproject/models/invoice.dart';
import 'package:testproject/models/sycsalerows.dart';
import 'package:testproject/models/syncInvoice.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/utils/http.dart';
import './tablesSchema.dart';
import '../models/postSale.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database? database;
  PrefService _prefs = PrefService();

  DatabaseHelper._privateConstructor();

  Future<Database?> databaseConnection() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //deleteDatabase(join(documentsDirectory.toString(), 'databasepath13.db'));

    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    print(await getApplicationDocumentsDirectory());
    database = await openDatabase(
      join(documentsDirectory.toString(), 'databasepath14.db'),
      onCreate: ((db, version) {
        return {
          db.execute(invoiceTableSql),
          db.execute(paymentTableSql),
          db.execute(saleRowTableSql),
          db.execute(customerSql),
          db.execute(accountsTableSql),
          db.execute(productsTableSql),
          db.execute(usersTableSql),
          db.execute(printerSetup),
          db.execute(inventoryTableSql),
          db.execute(uomsTableSql),
          db.execute(uomGroups),
          db.execute(ugp1TableSql),
          db.execute(versionTableSql),
          db.execute(outsourcedsTableSql)
        };
      }),
      version: 1,
    );
    //setheaders to fet id and store id

    //insertPayment();

    final firstInsert = await database!.query('version', where: 'id = 1');

    if (firstInsert.isEmpty || firstInsert[0]['products_inserted'] == 0) {
      syncProducts(database);
      syncAccountsModes(database);
      syncCustomers(database);
    }

    return database;
  }

  sethenders() async {
    var cache = await _prefs.readCache(
        'Token', 'StoreId', 'loggedinUserName', 'storename');

    String token = cache['Token'];
    String storeId = cache['StoreId'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };
    return headers;
  }

// Sync products from the online api
  Future<void> syncProducts(database) async {
    //fecth products online \

    var productsData = await GetProducts().getProductsList('');
    print(productsData);
    //initialize database
    final db = await database;

    await db.transaction((txn) async {
      for (var productData in productsData) {
        // Handle SUoMEntry
        // print(productData);
        productData['SUoMEntry'] = productData['SUoMEntry'] ??
            null; // Adjust based on your requirements
        //print(productData['SUoMEntry']);
        // Handle itm4
        productData['itm4'] = jsonEncode(productData['itm4']);
        // check if the record exisirt in the products table
        final exisitingRecord = await txn
            .query('products', where: 'id =?', whereArgs: [productData['id']]);

        if (exisitingRecord.isEmpty) {
          await txn.insert(
            'products',
            productData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
    // update the version table to indicate that the inital data has been inserted
    await db.update('version', {'products_inserted': 1}, where: 'id = 1');
    print("done");
  }

// Sync payment modes
  Future<void> syncAccountsModes(database) async {
    // Get a reference to the database.
    final db = await database;
    var bankAccounts = await GetProducts().getaccounts('');
    //print(bankAccounts);

    await db.transaction((txn) async {
      for (var account in bankAccounts) {
        //print(account);
        // check if the record exisirt in the accounts table
        final exisitingRecord = await txn
            .query('payments', where: 'id =?', whereArgs: [account["id"]]);

        if (exisitingRecord.isEmpty) {
          await txn.insert(
            'accounts',
            account,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }
//sync customers

  Future<void> syncCustomers(database) async {
    // Get a reference to the database.
    final db = await database;
    var customers = await GetProducts().getcustomers('');
    //print(customers);

    await db.transaction((txn) async {
      for (var customer in customers) {
        // print(customer);
        final exisitingRecord = await txn
            .query('customers', where: 'id =?', whereArgs: [customer["id"]]);
        if (exisitingRecord.isEmpty) {
          await txn.insert(
            'customers',
            customer,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>>? getAllProducts(searchTerm) async {
    // Get a reference to the database.
    print('getting products');
    Database? database = await databaseConnection();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        "SELECT id, Name, SellingPrice,o_p_l_n_s_id,itm1, itm4 FROM products WHERE Name LIKE '%$searchTerm%'");

    return maps;
  }

  Future<List<Map<String, dynamic>>>? getAllAccounts() async {
    // Get a reference to the database.
    Database? database = await databaseConnection();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> mapsAccounts =
        await database!.query('accounts');

    // print(
    //     '............................................................$mapsAccounts');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return mapsAccounts;
  }

  Future<List<Map<String, dynamic>>>? getAllCustomers() async {
    // Get a reference to the database.
    Database? database = await databaseConnection();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> mapsCustomers =
        await database!.query('customers');

    //print(
    //   '............................................................$mapsCustomers');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return mapsCustomers;
  }

  Future<void> postSale(PosSale salesCard) async {
    var headers = await sethenders();

    // Get a reference to the database.
    Database? database = await databaseConnection();
    //insert array of payments to  to payment table

    await database!.transaction((txn) async {
      var invoice = new Invoice(
        saleStatus: 0,
        soldBy: salesCard.soldBy,
        storeId: int.parse(headers['storeid']),
        balance: salesCard.balance,
        cardCode: salesCard.cardCode!,
        docTotal: salesCard.docTotal,
        objType: salesCard.objType,
        totalPaid: salesCard.totalPaid,
      );
      print(
          'invoice to be inserted .............................................. $invoice');
      var lastInsertedInvoice = await txn.insert(
        'invoices',
        invoice.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print(
          'last inserted invoice .............................................. $lastInsertedInvoice');
      for (var payment in salesCard.payments) {
        var newPayment = new Payment(
            accountId: payment.accountId,
            invoiceId: lastInsertedInvoice,
            storeId: int.parse(headers['storeid']),
            cardCode: salesCard.cardCode!,
            paymentRemarks: payment.paymentRemarks,
            soldBy: salesCard.soldBy,
            recieptNo: lastInsertedInvoice,
            sumApplied: payment.sumApplied);

        // check if the record exisirt in the accounts table

        var lastpaymentInserted = await txn.insert(
          'payments',
          newPayment.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print(
            'last inserted payment .............................................. $lastpaymentInserted');
      }

      for (var salesrow in salesCard.rows) {
        var newSaleRow = new SaleRow(
            invoiceId: lastInsertedInvoice,
            cardCode: salesCard.cardCode!,
            storeId: int.parse(headers['storeid']),
            oITMSId: salesrow.oITMSId,
            name: salesrow.name,
            uomEntry: salesrow.uomEntry,
            quantity: salesrow.quantity,
            price: salesrow.price,
            lineNum: salesrow.lineNum,
            lineTotal: salesrow.lineTotal,
            // soldBy: salesCard.soldBy,
            receiptNo: lastInsertedInvoice,
            cancelled: 0);

        var lastInsertedSaleRow = await txn.insert(
          'sale_rows',
          newSaleRow.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print(
            'last inserted salesrow .............................................. $lastInsertedSaleRow');
      }
    });
  }

  Future<List<Map<String, dynamic>>>? getAllSoldProducts() async {
    // Get a reference to the database.
    print('getting sold products');
    Database? database = await databaseConnection();
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        "SELECT * FROM sale_rows WHERE cancelled = 0 ORDER BY id DESC");
    print(maps);
    return maps;
  }

  Future<List<SyncInvoice>> fetchAllInvoiceDetails() async {
    // Get a reference to the database.
    Database? database = await databaseConnection();

    // Query the 'invoices' table for all invoices.
    List<Map<String, dynamic>> allInvoiceMaps =
        await database!.query('invoices', where: 'sale_status = 0');

    List<SyncInvoice> allInvoices = [];

    for (Map<String, dynamic> invoiceMap in allInvoiceMaps) {
      // Query the 'payments' table for payments with the given invoice ID.
      List<Map<String, dynamic>> paymentMaps = await database.query(
        'payments',
        where: 'invoice_id = ?',
        whereArgs: [invoiceMap['id']],
        // Assuming 'id' is the name of the invoice ID field
      );
      // Convert the List<Map> to a List<Payment>.
      List<SyncPayment> payments =
          paymentMaps.map((map) => SyncPayment.fromJson(map)).toList();
      // Query the 'sale_rows' table for sale rows with the given invoice ID.
      List<Map<String, dynamic>> saleRowMaps = await database.query(
        'sale_rows',
        where: 'invoice_id = ?',
        whereArgs: [
          invoiceMap['id']
        ], // Assuming 'id' is the name of the invoice ID field
      );

      // Convert the List<Map> to a List<SaleRow>.
      List<SyncSaleRow> saleRows =
          saleRowMaps.map((map) => SyncSaleRow.fromJson(map)).toList();

      // Add the payments and sale rows to the invoice map.
      Map<String, dynamic> invoiceMapMutable =
          Map<String, dynamic>.from(invoiceMap);
      invoiceMapMutable['payments'] = payments;
      invoiceMapMutable['rows'] = saleRows;

      // Convert the Map to an Invoice object and add it to the list.
      allInvoices.add(SyncInvoice.fromJson(invoiceMapMutable));
    }
    try {
      var response = await httpPost('sales-sync', allInvoices);
      var responsedata = jsonDecode(response.body);
      print(
          responsedata); // Note: responsedata is a Map, not an object with properties
    } catch (e) {
      print('Caught error: $e');
    }
    print(
        'invoice array ...................................................$allInvoices');
    for (var invoice in allInvoices) {
      print(
          '-----------------------------------------------------------------------' +
              '${invoice.toJson()}');
    }

    return allInvoices;
  }

  // create a method to sync sales to online api and update the local database
  Future<void> syncSales() async {
    // Get a reference to the database.
    Database? database = await databaseConnection();
    // Query the 'invoices' table for all invoices.
    List<Map<String, dynamic>> allInvoiceMaps =
        await database!.query('invoices', where: 'sale_status = 0');

    List<SyncInvoice> allInvoices = [];

    for (Map<String, dynamic> invoiceMap in allInvoiceMaps) {
      // Query the 'payments' table for payments with the given invoice ID.
      List<Map<String, dynamic>> paymentMaps = await database.query(
        'payments',
        where: 'invoice_id = ?',
        whereArgs: [invoiceMap['id']],
        // Assuming 'id' is the name of the invoice ID field
      );
      // Convert the List<Map> to a List<Payment>.
      List<SyncPayment> payments =
          paymentMaps.map((map) => SyncPayment.fromJson(map)).toList();
      // Query the 'sale_rows' table for sale rows with the given invoice ID.
      List<Map<String, dynamic>> saleRowMaps = await database.query(
        'sale_rows',
        where: 'invoice_id = ?',
        whereArgs: [
          invoiceMap['id']
        ], // Assuming 'id' is the name of the invoice ID field
      );

      // Convert the List<Map> to a List<SaleRow>.
      List<SyncSaleRow> saleRows =
          saleRowMaps.map((map) => SyncSaleRow.fromJson(map)).toList();

      // Add the payments and sale rows to the invoice map.
      Map<String, dynamic> invoiceMapMutable =
          Map<String, dynamic>.from(invoiceMap);
      invoiceMapMutable['payments'] = payments;
      invoiceMapMutable['rows'] = saleRows;

      // Convert the Map to an Invoice object and add it to the list.
      allInvoices.add(SyncInvoice.fromJson(invoiceMapMutable));
    }

    // print(allInvoices);
    // print('....................................................');
    // print(allInvoices[0].toJson());
    // print('....................................................');
    // print(allInvoices[0].payments[0].toJson());
    // print('....................................................');
    // print(allInvoices[0].rows[0].toJson());
    // print('....................................................');

    // print(allInvoices[0].toJson());
    // print('
  }
}
