import 'package:http/http.dart' as http;
import './shared_data.dart';

var backendUrl = 'https://prestige-nhg7.onrender.com';
// var backendUrl = 'http://10.0.2.2:8300';

Future<dynamic> getSharedData() async {
  final prefsData = await sharedData();
  dynamic storeId;
  dynamic token;

  if (prefsData['storeId'] != null) {
    storeId = prefsData['storeId'];
  }

  if (prefsData['token'] != null) {
    token = prefsData['token'];
  } else {

  }

  final headers = <String, String>{
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
    'storeid': '$storeId',
  };

  final data = {'headers': headers};
  return data;
}

Future<dynamic> httpPostLogin(String apiUrl, dynamic data) async {
  try {
    final url = Uri.parse('$backendUrl/$apiUrl');
    final prefsData = await getSharedData();
    final response = await http.post(
      url,
      headers: prefsData['headers'],
      body: data,
    );

    return response;
  } catch (error) {
    print(error.toString());
    return error;
  }
}

Future<dynamic> httpPost(String apiUrl, dynamic data) async {
  try {
    final url = Uri.parse('$backendUrl/$apiUrl');
    final prefsData = await getSharedData();
    final response = await http.post(
      url,
      headers: prefsData['headers'],
      body: data,
    );

    return response;
  } catch (error) {
    print(error.toString());
    return error;
  }
}

Future<dynamic> httpGet(String apiUrl) async {
  try {
    final url = Uri.parse('$backendUrl/$apiUrl');
    final prefsData = await getSharedData();
    final headers = prefsData['headers'];

    print('headers ${headers['storeId']}');

    final response = await http.get(url, headers: prefsData['headers']);
    return response;
  } catch (error) {
    print(error.toString());
  }
}

