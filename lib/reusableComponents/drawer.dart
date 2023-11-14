import 'package:flutter/material.dart';

class DrawerNavigation extends StatelessWidget {
  const DrawerNavigation({
    Key? key,
    required this.storename,
  }) : super(key: key);

  final String storename;

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
                  decoration: BoxDecoration(),
                ),
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
            // ListTile(
            //   title: const Text('Customer Deposit'),
            //   onTap: () {
            //     // Update the state of the app
            //     // ...
            //     // Then close the drawer
            //     Navigator.pushNamed(context, '/customerDeposit');
            //   },
            // ),
            /* ListTile(
              title: const Text('Invetory'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/inventory');
              },
            ), */
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
            /*  ListTile(
                title: const Text('Transfer'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/transfer');
                }), */
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
      ),
    );
  }
}
