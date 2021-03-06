import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart';

class Api {
  static post({path, dynamic params, Function errorCallback}) async {
    if (params == null) {
      params = {};
    }

    if (jsonEncode(params) == null) {
      throw new FormatException("Invalid params");
    }

    var uri = Uri.https(BASE_URL, path);
    var res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': await loadJwt(),
          'JWT_AUD': AUD
        },
        body: jsonEncode(params)
    );

    if (res.statusCode == 401) {
      if (errorCallback != null) errorCallback(401);
      return null;
    }

    if (res.statusCode == 500) {
      if (errorCallback != null) errorCallback(500);
      return null;
    }

    if (res.statusCode == 200) return jsonDecode(res.body);

    return null;
  }

  static put({path, id, params}) async {
    if (params == null) {
      params = {};
    }

    if (jsonEncode(params) == null) {
      throw new FormatException("Invalid params");
    }

    var uri = Uri.https(BASE_URL, path);
    var res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': await loadJwt(),
          'JWT_AUD': AUD
        },
        body: jsonEncode(params)
    );

    if (res.statusCode == 401) {
      return null;
    }

    if (res.statusCode == 500) {
      return null;
    }

    if (res.statusCode == 200) return jsonDecode(res.body);

    return null;
  }

  static delete({path, id, params}) async {

  }

  static get({path, Map<String, String> params}) async {
    if (params == null) {
      params = new Map<String, String>();
    }

    if (jsonEncode(params) == null) {
      throw new FormatException("Invalid params");
    }

    var uri = Uri.https(BASE_URL, path, params);
    var res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': await loadJwt(),
          'JWT_AUD': AUD
        }
    );

    if (res.statusCode == 401) {
      return null;
    }

    if (res.statusCode == 500) {
      return null;
    }

    if (res.statusCode == 200) return jsonDecode(res.body);

    return null;

  }

  static loadJwt() async {
      return await storage.read(key: "jwt");
  }
}