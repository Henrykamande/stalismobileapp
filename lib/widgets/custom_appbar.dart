import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// import '../providers/auth.dart';
import '../utils/shared_data.dart';
// import '../utils/sync_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  var userName = '';
  var storeName = '';

  dynamic getUser() async {
    final prefsData = await sharedData();
    setState(() {
      userName = prefsData['name'];
    });
  }

  dynamic getStoreName() async {
    final prefsData = await sharedData();
    setState(() {
      storeName = prefsData['storeName'];
    });
  }

  @override
  void initState() {
    getUser();
    getStoreName();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   // final internetStatus = Provider.of<SyncService>(context).internetConnectivity;

    return AppBar(
      backgroundColor: Colors.grey.shade700,
      title: Text('Stalis Pos', style: TextStyle(fontSize: 16),),
      // backgroundColor: internetStatus == ConnectivityResult.none ? Colors.deepOrange : Colors.indigo,
      actions: [
        Row(
          children: [
            // Row(
            //   children: [
            //     internetStatus == ConnectivityResult.none ? const Text('No Internet !') : const Text('Internet Connected'),
            //     const SizedBox(
            //       width: 20,
            //     ),
            //     internetStatus == ConnectivityResult.none
            //         ? const Icon(
            //       Icons.signal_wifi_connected_no_internet_4_sharp,
            //     )
            //         : const Icon(
            //       Icons.wifi,
            //       color: Colors.greenAccent,
            //     )
            //   ],
            // ),
            const SizedBox(
              width: 20,
            ),
            Text('$userName!'),
            const SizedBox(width: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/');
               // Provider.of<Auth>(context, listen: false).logout();
              },
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
      ],
    );
  }

// @override
// Size get preferredSize => const Size.fromHeight(50);
}
