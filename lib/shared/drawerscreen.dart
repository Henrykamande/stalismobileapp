import 'package:flutter/material.dart';
import 'package:testproject/providers/login_service.dart';
import 'package:provider/provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  PrefService _prefs = PrefService();
  var cache;
  String storename = '';
  @override
  void initState() {
    sethenders();
    super.initState();
  }

  sethenders() async {
    cache = await _prefs.readCache(
        'Token', 'StoreId', 'loggedinUserName', 'storename');

    String token = cache['Token'];
    String storeId = cache['StoreId'];

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
      "storeid": "$storeId"
    };
    setState(() {
      storename = cache['storename'];
    });
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Drawer(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              child: DrawerHeader(
                child: ListTile(
                  title: Text(storename),
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
              ),
              decoration: BoxDecoration(),
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
            title: const Text('Sold Products'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/soldproducts');
            },
          ),
          ListTile(
            title: const Text('Payments'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/salepayments');
            },
          ),
          ListTile(
            title: const Text('Create Deposit'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/customerDeposit');
            },
          ),
          ListTile(
              title: Text('Deposits'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/customerdepositlist');
              }),
          ListTile(
            title: const Text('Return & Replacement'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/customercreditnote');
            },
          ),
          ListTile(
            title: const Text('Returned Products'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/returnedproducts');
            },
          ),
          ListTile(
            title: const Text('SetUp Printer'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/defaultprinter');
            },
          ),
        ],
      ),
    ));
  }
}
