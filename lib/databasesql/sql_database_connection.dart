import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:testproject/models/SyncPayment.dart';
import 'package:testproject/models/customer.dart';
import 'package:testproject/models/invoice.dart';
import 'package:testproject/models/sycsalerows.dart';
import 'package:testproject/models/syncInvoice.dart';
import 'package:testproject/providers/accounts.dart';

import 'package:testproject/providers/api_service.dart';
import 'package:testproject/providers/customer.dart';
import 'package:testproject/providers/products.dart';
import 'package:testproject/utils/http.dart';
import '../models/accountmodel.dart';
import '../models/product.dart';
import '../utils/shared_data.dart';
import './tables_schema.dart';
import '../models/postSale.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database? database;
  DatabaseHelper._privateConstructor();

  Future<Database?> databaseConnection() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    print(await getApplicationDocumentsDirectory());
    database = await openDatabase(
      join(documentsDirectory.toString(), 'stalispos17.db'),
      onCreate: ((db, version) {
        return {
          db.execute(invoiceTableSql),
          db.execute(paymentTableSql),
          db.execute(saleRowTableSql),
          db.execute(customerSql),
          db.execute(accountsTableSql),
          db.execute(productsTableSql),
          // db.execute(usersTableSql),
          // db.execute(printerSetup),
          // db.execute(inventoryTableSql),
          // db.execute(uomsTableSql),
          // db.execute(uomGroups),
          // db.execute(ugp1TableSql),
          // db.execute(versionTableSql),
          // db.execute(outsourcedsTableSql)
        };
      }),
      version: 1,
    );

    // final firstInsert = await database!.query('version', where: 'id = 1');
    //
    // if (firstInsert.isEmpty || firstInsert[0]['products_inserted'] == 0) {
    syncCustomers(database);
    syncProducts(database);
    syncAccounts(database);

    // }
    return database;
  }

  setHeaders() async {
    final prefsData = await sharedData();

    String token = prefsData['token'];
    String storeId = prefsData['storeId'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };

    return headers;
  }

  Future<void> syncCustomers(database) async {
    // Get a reference to the database.
    final db = await database;
    var customers = await CustomerProvider().fetchCustomers();

    await db.transaction((txn) async {
      for (var customer in customers) {
        var newCustomer = new Customer(
            id: customer['id'],
            name: customer['Name'],
            phoneNumber: customer['PhoneNumber'],
            email: customer['Email'],
            subscriberId: customer['SubscriberId']);

        final existingRecord = await txn
            .query('customers', where: 'id = ?', whereArgs: [customer["id"]]);

        if (existingRecord.isEmpty) {
          await txn.insert(
            'customers',
            newCustomer.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<List<dynamic>> getAllCustomers() async {
    Database? database = await databaseConnection();
    final List<Map<String, dynamic>> mapsCustomers =
        await database!.query('customers');

    return mapsCustomers;
  }

  Future<void> syncAccounts(database) async {
    final db = await database;
    var bankAccounts = await AccountsProvider().fetchAccounts();

    await db.transaction((txn) async {
      for (var account in bankAccounts) {
        var newAccount = new Account(
            id: account['id'],
            name: account['Name'],
            subscriberId: account['subscriberid']);

        final existingRecord = await txn
            .query('accounts', where: 'id =?', whereArgs: [account["id"]]);

        if (existingRecord.isEmpty) {
          await txn.insert(
            'accounts',
            newAccount.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<List<dynamic>> getAllAccounts() async {
    Database? database = await databaseConnection();
    final List<Map<String, dynamic>> mapsAccounts =
        await database!.query('accounts');

    return mapsAccounts;
  }

// Sync products from the online api
  Future<void> syncProducts(database) async {
    var productsData = await ProductsProvider().fetchProducts();
    final db = await database;

    await db.transaction((txn) async {
      for (var product in productsData) {
        var newProduct = new Product(
            id: product['id'],
            name: product['Name'],
            barcode: product['BarCode'],
            itemType: product['ItemType'],
            buyingPrice: double.parse(product['BuyingPrice'].toString()),
            sellingPrice: double.parse(product['SellingPrice'].toString()),
            leastPrice: double.parse(product['LeastPrice'].toString()),
            availableQty: double.parse(product['AvailableQty'].toString()),
            hasUom: product['HasUom']);

        final existingRecord = await txn
            .query('products', where: 'id =?', whereArgs: [product['id']]);

        if (existingRecord.isEmpty) {
          await txn.insert(
            'products',
            newProduct.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<List<dynamic>> getAllProducts() async {
    Database? database = await databaseConnection();
    final List<Map<String, dynamic>> mapProducts =
    await database!.query('products');

    return mapProducts;
  }


  Future<List<Map<String, dynamic>>>? searchProducts(searchTerm) async {
    Database? database = await databaseConnection();
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        "SELECT id, Name, SellingPrice, AvailableQty FROM products WHERE Name LIKE '%$searchTerm%'");
    return maps;
  }

  Future<List<Map<String, dynamic>>> searchCustomers(searchTerm) async {
    print(' customer search term $searchTerm');
    Database? database = await databaseConnection();
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        "SELECT id, Name, PhoneNumber FROM customers WHERE Name LIKE '%$searchTerm%'");
    return maps;
  }

  Future<void> postSale(PosSale salesCard) async {
    var prefsData = await sharedData();
    // Get a reference to the database.
    Database? database = await databaseConnection();
    //insert array of payments to  to payment table

    await database!.transaction((txn) async {
      var invoice = new Invoice(
        saleStatus: 0,
        soldBy: salesCard.soldBy,
        storeId: prefsData['storeId'],
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
            storeId: prefsData['storeId'],
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

      for (var salesRow in salesCard.rows) {
        var newSaleRow = new SaleRow(
            invoiceId: lastInsertedInvoice,
            cardCode: salesCard.cardCode!,
            storeId: prefsData['storeId'],
            oITMSId: salesRow .oITMSId,
            name: salesRow .name,
            uomEntry: salesRow.uomEntry,
            quantity: salesRow.quantity,
            price: salesRow.price,
            lineNum: salesRow.lineNum,
            lineTotal: salesRow.lineTotal,
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

  }
}
