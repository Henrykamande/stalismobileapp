import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerScreen extends StatelessWidget {
  final String storename;
  DrawerScreen({required this.storename});

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
          // ListTile(
          //   title: const Text('Create Deposit'),
          //   onTap: () {
          //     // Update the state of the app
          //     // ...
          //     // Then close the drawer
          //     Navigator.pushNamed(context, '/customerDeposit');
          //   },
          // ),
          // ListTile(
          //     title: Text('Deposits'),
          //     onTap: () {
          //       // Update the state of the app
          //       // ...
          //       // Then close the drawer
          //       Navigator.pushNamed(context, '/customerdepositlist');
          //     }),
          // ListTile(
          //   title: const Text('Return & Replacement'),
          //   onTap: () {
          //     // Update the state of the app
          //     // ...
          //     // Then close the drawer
          //     Navigator.pushNamed(context, '/customercreditnote');
          //   },
          // ),
          // ListTile(
          //   title: const Text('Returned Products'),
          //   onTap: () {
          //     // Update the state of the app
          //     // ...
          //     // Then close the drawer
          //     Navigator.pushNamed(context, '/returnedproducts');
          //   },
          // ),
          /*   ListTile(
              title: const Text('Transfer'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/transfer');
              }), */
          // ListTile(
          //   title: const Text('Gas Sale'),
          //   onTap: () {
          //     // Update the state of the app
          //     // ...
          //     // Then close the drawer
          //     Navigator.pushNamed(context, '/gassale');
          //   },
          // ),
          ListTile(
            title: const Text('General Settings'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pushNamed(context, '/generalsettings');
            },
          ),
          ListTile(
              title: const Text('Web Portal'),
              onTap:
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  () => launch('https://stalis.softcloudtech.co.ke/login')),
        ],
      ),
    ));
  }
}
