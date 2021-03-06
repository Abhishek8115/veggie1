import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';
import 'login.dart';
import 'widgets.dart';
import 'cache.dart';

String domain = 'https://cts.archerstack.com';
String id, password;
String s3Domain = 'https://archerstack.s3.eu-central-003.backblazeb2.com/';
Client http = Client();
bool showingErrorDialog = false;
Future<Response> postMap(
    String url, Map<String, String> map, BuildContext context) async {
  try {
    map.putIfAbsent('vendorId', () => Cache.vendorId);
    map.putIfAbsent('outletId', () => Cache.outletId);
    var response = await http.post(domain + url, body: map);
    if (response.statusCode == 300) {
      File config =
          new File((await getApplicationDocumentsDirectory()).path + '/config');
      if (config.existsSync()) config.deleteSync();
      id = null;
      password = null;
      await showDialog(
          context: context,
          builder: (context) =>
              MessageDialog(message: 'Session expired. Log in again'));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false);
      return response;
    }
    if (response.statusCode != 200) {
      await showDialog(
          context: context,
          builder: (context) => MessageDialog(message: response.body));
      return response;
    }
    return response;
  } catch (e) {
    if (showingErrorDialog) return Response('Cannot connect to server', 500);
    showingErrorDialog = true;
    await showDialog(
        context: context,
        builder: (context) =>
            MessageDialog(message: 'Cannot connect to server'));
    showingErrorDialog = false;
    return Response('Cannot connect to server', 500);
  }
}

Future<Response> upload(
    String url, String jsonString, String path, BuildContext context) async {
  Response response;
  try {
    MultipartRequest request =
        MultipartRequest("POST", Uri.parse(domain + url));
    request.files.add(await MultipartFile.fromPath("file", path));
    request.fields.putIfAbsent('data', () => jsonString);
    response = await Response.fromStream(await request.send());
    if (response.statusCode == 300) {
      File config =
          new File((await getApplicationDocumentsDirectory()).path + '/config');
      if (config.existsSync()) config.deleteSync();
      id = null;
      password = null;
      await showDialog(
          context: context,
          builder: (context) =>
              MessageDialog(message: 'Session expired. Log in again'));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false);
      return response;
    }
    if (response.statusCode != 200) {
      await showDialog(
          context: context,
          builder: (context) =>
              MessageDialog(message: 'Failed to upload. Try again'));
      return response;
    }
    return response;
  } catch (e) {
    await showDialog(
        context: context,
        builder: (context) =>
            MessageDialog(message: 'Cannot connect to server'));
    return response;
  }
}

Future<Response> getRequest(String uri) async {
  Response response;
  response = await http.get(uri);
  return response;
}
