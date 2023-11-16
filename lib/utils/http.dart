import 'package:http/http.dart' as http;
import './shared_data.dart';

var backendUrl = 'https://phplaravel-1005299-3647050.cloudwaysapps.com/api/v1';
//var backendUrl = 'http://10.0.2.2:8000/api/v1';

Future<dynamic> getSharedData() async {
  final prefsData = await sharedData();
  dynamic storeId;
  dynamic token;

  if (prefsData['storeId'] != null) {
    storeId = prefsData['storeId'];
  }

  if (prefsData['token'] != null) {
    token = prefsData['token'];
  }

  final headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
    'storeid': '$storeId',
  };

  final data = {'headers': headers};
  return data;
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
    return error;
  }
}

Future<dynamic> httpGet(String apiUrl) async {
  try {
    final url = Uri.parse('$backendUrl/$apiUrl');
    final prefsData = await getSharedData();

    final response = await http.get(url, headers: prefsData['headers']);
    return response;
  } catch (error) {
    print(error.toString());
  }
}
