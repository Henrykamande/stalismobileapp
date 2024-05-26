import 'package:flutter/material.dart';
import 'package:testproject/databasesql/sql_database_connection.dart';
import 'package:testproject/pages/productsPages/addProductForm.dart';
import 'package:testproject/models/product.dart';
import 'package:testproject/providers/api_service.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'package:testproject/providers/shared_preferences_services.dart';
import 'package:testproject/widgets/custom_appbar.dart';
import 'package:testproject/widgets/drawer_screen.dart';

class CustomersListScreen extends StatefulWidget {
  static const routeName = '/customers-list';
  const CustomersListScreen ({Key? key}) : super(key: key);

  @override
  State<CustomersListScreen> createState() => _CustomersListState();
}

class _CustomersListState extends State<CustomersListScreen> {
  late Future<List<dynamic>> customersList;

  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    customersList = DatabaseHelper.instance.getAllCustomers();
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
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: Container(
                  child: FutureBuilder<List<dynamic>>(
                      future: customersList,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {}
                        if (snapshot.hasData) {
                          List<dynamic> result = snapshot.data!;

                          return ListView.builder(
                            itemCount: result.length,
                            itemBuilder: (context, index) => InkWell(
                              onTap: () {},
                              child: ListTile(
                                title: Text(result[index]['Name']),
                                // subtitle: Text(result[index]['PhoneNumber']),
                                trailing: Text(
                                    '${result[index]['PhoneNumber'].toString()}'),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
