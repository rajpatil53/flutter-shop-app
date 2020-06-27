import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryTime;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryTime != null &&
        _expiryTime.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlPath) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlPath?key=AIzaSyAVOnbgsM3EWryC5vwUlTeHe-CKhr2kRMY';
    try {
      final resp = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final respData = json.decode(resp.body);
      if (respData['error'] != null) {
        throw HttpException(respData['error']['message']);
      }
      _token = respData['idToken'];
      _userId = respData['localId'];
      _expiryTime = DateTime.now()
          .add(Duration(seconds: int.parse(respData['expiresIn'])));
      notifyListeners();
      autoLogout();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'userData',
          json.encode({
            'token': _token,
            'userId': _userId,
            'expiryTime': _expiryTime.toIso8601String(),
          }));
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> signup(String email, String password, String urlPath) async {
    return _authenticate(email, password, urlPath);
  }

  Future<void> login(String email, String password, String urlPath) async {
    return _authenticate(email, password, urlPath);
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryTime = null;
    notifyListeners();
    _authTimer.cancel();
    _authTimer = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> autoLogout() async {
    if (_authTimer != null) _authTimer.cancel();
    final timeToExpiry = _expiryTime.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userData = json.decode(prefs.getString('userData'));
    final expiryTime = DateTime.parse(userData['expiryTime']);
    if (expiryTime.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryTime = expiryTime;
    notifyListeners();
    return true;
  }
}
