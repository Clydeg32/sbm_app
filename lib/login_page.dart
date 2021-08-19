import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart';
import './main.dart';

// https://dev.to/carminezacc/user-authentication-jwt-authorization-with-flutter-and-node-176l
class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<String> attemptLogIn(String username, String password) async {
    var uri = Uri.https(BASE_URL, '/auth/users/sign_in');
    var res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'JWT_AUD': AUD
        },
        body: jsonEncode({
          "user": {
            "email": username,
            "password": password
          }
        })
    );
    if(res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      var user = jsonDecode(res.body);
      prefs.setString('user', jsonEncode(user));

      return res.headers["authorization"];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log In")),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                  labelText: 'Email'
              ),
            ),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password'
                )
            ),
            FlatButton(
                child: Text("Log In"),
                onPressed: () async {
                  var username = _usernameController.text;
                  var password = _passwordController.text;
                  var jwt = await attemptLogIn(username, password);
                  if(jwt != null) {
                    storage.write(key: "jwt", value: jwt);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage.fromBase64(jwt)
                        )
                    );
                  } else {
                    displayDialog(context, "An Error Occurred", "No account was found matching that username and password");
                  }
                }
            )
          ]
        )
      )
    );
  }

}

void displayDialog(BuildContext context, String title, String text) =>
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
              title: Text(title),
              content: Text(text)
          ),
    );

