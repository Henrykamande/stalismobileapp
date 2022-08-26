import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:testproject/models/postSale.dart';

import 'package:testproject/models/product.dart';

class DefaultPrinter with ChangeNotifier {
  String defualtprinter = '';

  String get defaultPrinter {
    return defaultPrinter;
  }

  void setdefaultPrinter(defualtP) {
    defualtprinter = defualtP;
    notifyListeners();
  }
}
