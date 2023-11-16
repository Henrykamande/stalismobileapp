import 'package:flutter/material.dart';
import 'package:testproject/providers/productslist_provider.dart';

void customSnackBar(context, text) {
  final snackBar = SnackBar(
    content: Container(
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          )),
      height: 90.0,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
