import 'package:flutter/material.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';
import '../widgets/custom_appbar.dart';

import '../widgets/drawer_screen.dart';
import '../utils/shared_data.dart';


class DataSyncScreen extends StatefulWidget {
  static const routeName = '/data-sync';

  const DataSyncScreen({Key? key}) : super(key: key);

  @override
  State<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends State<DataSyncScreen> {
  var storeName = '';
  bool _isLoading = false;

  setHeaders() async {
    final prefsData = await sharedData();
    setState(() {
      storeName = prefsData['storeName'];
    });
  }

  Future<dynamic> syncData() async {
    setState(() {
      _isLoading = true;
    });
   await DatabaseHelper.instance.databaseConnection().then((value) {
     setState(() {
       _isLoading = false;
     });
   });
  }

  @override
  void initState() {
    setHeaders();
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerScreen(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: _isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: syncData, child: Text('Sync All Data')))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
