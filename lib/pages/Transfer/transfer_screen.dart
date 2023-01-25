import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testproject/main.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:testproject/providers/productslist_provider.dart';
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/reusableComponents/bottomNavigation.dart';

class TransferScreen extends StatefulWidget {
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  PrefService _prefs = PrefService();
  TextEditingController dateInput = TextEditingController();

  var selectedStore;
  var selectedPickedBy;
  var allUsers = [];
  var cache;
  bool setdate = true;

  var _storename;
  List allStores = [];
  @override
  void initState() {
    super.initState();
    fetchallStores();
    fetchallUsers();
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
      _storename = cache['storename'];
    });
    return headers;
  }

  void fetchallStores() async {
    var headers = await sethenders();

    var url =
        Uri.https('apoyobackend.softcloudtech.co.ke', '/api/v1/all/stores');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {}
    setState(() {
      allStores = jsonDecode(response.body)['ResponseData'];
      print("All Stores $allStores");
    });
    print("all stores $allStores");
  }

  void fetchallUsers() async {
    var headers = await sethenders();

    var url = Uri.https('apoyobackend.softcloudtech.co.ke', '/api/v1/users');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {}
    setState(() {
      allUsers = jsonDecode(response.body)['ResponseData'];
      print("All Users $allUsers");
    });
    print("all Users $allUsers");
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    //allStores = Provider.of<GetProducts>(context, listen: false).allStores;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade700,
          title: Center(
            child: Text(
              'Transfer',
              style: TextStyle(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                cache = await _prefs.readCache(
                  'Token',
                  'StoreId',
                  'loggedInUserName',
                  'storename',
                );
                print(cache['Token']);
                await _prefs.removeCache(
                    'Token', 'StoreId', 'loggedInUserName', 'storename');
                print(cache);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Stalisapp()));
              },
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DropdownButton(
                              hint: Text(
                                'Select Shop',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: TextStyle(color: Colors.black),
                              isExpanded: false,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              ),
                              value: selectedStore,
                              focusColor: Colors.white,
                              dropdownColor: Colors.white,
                              items: allStores.map((store) {
                                return DropdownMenuItem(
                                  value: store['id'],
                                  child: Text(
                                    store['Name'].toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStore = value;
                                });
                                print(value);
                              }),
                          Flexible(
                            child: Consumer<ProductListProvider>(
                              builder: (context, value, child) {
                                return TextFormField(
                                  controller: dateInput,
                                  /* initialValue: (context
                                              .read<ProductListProvider>()
                                              .selectedDate !=
                                          '')
                                      ? context
                                          .read<ProductListProvider>()
                                          .selectedDate
                                      : '', */

                                  //editing controller of this TextField
                                  decoration: InputDecoration(
                                      icon: Icon(Icons
                                          .calendar_today), //icon of text field
                                      labelText: 'Date' //label text of field
                                      ),
                                  readOnly: true,
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        currentDate: DateTime.now(),
                                        //firstDate: DateTime(1900)
                                        firstDate: DateTime.now()
                                            .subtract(Duration(hours: 0)),
                                        //DateTime.now() - not to allow to choose before today.
                                        lastDate: DateTime(2100));

                                    if (pickedDate != null) {
                                      print(
                                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16

                                      dateInput.text = formattedDate;
                                      setdate = false;
                                      value.setselectedDate(dateInput.text);
                                      //set output date to TextField value.

                                    } else {
                                      DateTime now = new DateTime.now();
                                      DateTime date = new DateTime(
                                          now.year, now.month, now.day);
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd').format(date);
                                      dateInput.text = formattedDate;
                                      value.setSaleDate(dateInput
                                          .text); //set output date to TextField value.

                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Select Date';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
              Container(
                height: screenHeight * 0.5,
                child: Text(''),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Picked By"),
                  DropdownButton(
                      hint: Text(
                        'Picked By',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: TextStyle(color: Colors.black),
                      isExpanded: false,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      value: selectedPickedBy,
                      focusColor: Colors.white,
                      dropdownColor: Colors.white,
                      items: allUsers.map((user) {
                        return DropdownMenuItem(
                          value: user['id'],
                          child: Text(
                            user['name'].toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          print(value);
                          selectedPickedBy = value;
                        });
                        print(value);
                      }),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: () {}, child: Text("Transfer Stock"))
            ],
          ),
        ),
      ),
    );
  }
}
