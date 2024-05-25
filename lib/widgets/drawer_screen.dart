import 'package:flutter/material.dart';
import 'package:testproject/pages/data_sync.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Drawer(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height:80,
              child: DrawerHeader(
                child: ListTile(
                  title: Text('Stalis POS'),
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
            title: const Text('Sale Returns'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/returnedproducts');
            },
          ),
          ListTile(
            title: const Text('Return & Replacement'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/customercreditnote');
            },
          ),
          ExpansionTile(
            title: const Text('Stock Transfers'),
            // leading: const Icon(Icons.compare_arrows),
            childrenPadding: const EdgeInsets.only(left: 10.0),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Transfer Stock'),
                onTap: () {
                  Navigator.of(context).pushNamed('transfer');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Receive Stock'),
                onTap: () {
                  // Navigator.of(context).pushNamed(ViewTransfersScreen.routeName);
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Sales Reports'),
            // leading: const Icon(Icons.compare_arrows),
            childrenPadding: const EdgeInsets.only(left: 10.0),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Sold Products'),
                onTap: () {
                  Navigator.pushNamed(context, '/soldproducts');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Payments'),
                onTap: () {
                  Navigator.pushNamed(context, '/salepayments');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Returned Products'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/returnedproducts');
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Master Data'),
            // leading: const Icon(Icons.compare_arrows),
            childrenPadding: const EdgeInsets.only(left: 10.0),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Products'),
                onTap: () {
                  Navigator.of(context).pushNamed('transfer');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Customers'),
                onTap: () {
                  // Navigator.of(context).pushNamed(ViewTransfersScreen.routeName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Accounts'),
                onTap: () {
                  // Navigator.of(context).pushNamed(ViewTransfersScreen.routeName);
                },
              ),
            ],
          ),
          ListTile(
            title: const Text('Expenditure'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/generalsettings');
            },
          ),
          ListTile(
            title: const Text('Starting Float'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/generalsettings');
            },
          ),
          ListTile(
            title: const Text('Close Accounts'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/generalsettings');
            },
          ),
          ListTile(
            title: const Text('Sync Data'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.of(context).pushReplacementNamed(DataSyncScreen.routeName);
            },
          ),
          ListTile(
            title: const Text('Printer Setup'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/generalsettings');
            },
          ),
        ],
      ),
    ));
  }
}
