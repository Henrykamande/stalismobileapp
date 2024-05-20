// import 'dart:convert';

// import 'package:sqflite/sqflite.dart';

// import 'dart:async';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:testproject/databasesql/tablesSchema.dart';
// import 'package:testproject/providers/api_service.dart';

// class DatabaseHelper {
//   static DatabaseHelper? _databaseHelper;

//   static Database? _database;

//   DatabaseHelper._createInstance();

//   factory DatabaseHelper() {
//     if (_databaseHelper == null) {
//       _databaseHelper = DatabaseHelper?._createInstance();
//     }

//     return _databaseHelper!;
//   }

//   Future<Database> initializeDatabase() async {
//     Directory directory = await getApplicationDocumentsDirectory();

//     String path = directory.path + 'stalis_posdb.db';

//     var stalisDatabase =
//         await openDatabase(path, version: 1, onCreate: _createDb);
//     return stalisDatabase;
//   }

//   Future<Database> get database async {
//     if (_database == null) {
//       _database = await initializeDatabase();
//     }
//     return _database!;
//   }

//   void _createDb(Database db, int newVersion) async {
//     await {
//       db.execute(invoiceTableSql),
//       db.execute(paymentTableSql),
//       db.execute(saleRowTableSql),
//       db.execute(customerTableSql),
//       db.execute(accountsTableSql),
//       db.execute(productsTableSql),
//       db.execute(usersTableSql),
//       db.execute(printerSetup),
//       db.execute(inventoryTableSql),
//       db.execute(uomsTableSql),
//       db.execute(uomGroups),
//       db.execute(ugp1TableSql),
//       db.execute(versionTableSql),
//     };
//   }

//   void bulkInsertProducts() async {
//     // Get a reference to the database.
//     //fecth products online \
//     var productsData = await GetProducts().getProductsList('');
//     //initialize database
//     final db = await database;
//     //check if the initial data has been inserted
//     final firstInsert = await db.query('version', where: 'id = 1');

//     if (firstInsert.isEmpty || firstInsert[0]['products_inserted'] == 0) {
//       await db.transaction((txn) async {
//         for (var productData in productsData) {
//           // Handle SUoMEntry
//           // print(productData);
//           productData['SUoMEntry'] = productData['SUoMEntry'] ??
//               null; // Adjust based on your requirements
//           //print(productData['SUoMEntry']);
//           // Handle itm4
//           productData['itm4'] = jsonEncode(productData['itm4']);
//           // check if the record exisirt in the products table
//           final exisitingRecord = await txn.query('products',
//               where: 'id =?', whereArgs: [productData['id']]);

//           if (exisitingRecord.isEmpty) {
//             await txn.insert(
//               'products',
//               productData,
//               conflictAlgorithm: ConflictAlgorithm.replace,
//             );
//           }
//         }
//       });
//       // update the version table to indicate that the inital data has been inserted
//       await db.update('version', {'products_inserted': 1}, where: 'id = 1');
//       print("done");
//     }
//   }

//   Future<List<Map<String, dynamic>>> getLocalProductsList(userQuery) async {
//     Database db = await this.database;

//     var result = await db
//         .rawQuery("SELECT Name FROM products WHERE Name LIKE '%$userQuery%'");

//     print(result);
//     return result;
//   }
// }
