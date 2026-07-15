import 'global.dart';

Future<Map<String, String>> get headers async {
  String? token = Global.userToken;

  token ??= await Global.getUserToken();

  final Map<String, String> headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  if (token != null && token.trim().isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }

  return headers;
}
