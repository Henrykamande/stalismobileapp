import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:testproject/providers/login_service.dart';
import 'package:testproject/providers/shared_preferences_services.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserLogin _userLogin = UserLogin();
  PrefService _prefs = PrefService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String _errorMessage = '';
  bool _passwordVisible = true;
  bool isLoading = false;

  Future<void> _loginUser() async {
    setState(() {
      isLoading = true;
    });

    Provider.of<UserLogin>(context, listen: false).loginApi(passwordController.text.toString(),
        emailController.text.toString())
        .then((response) {
          print('result code ${response['ResultCode'] }');
      if (response['ResultCode'] == 1500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message']),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red),
        );
      }
      if (response['ResultCode'] == 1200) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/start', (route) => false);
      }

      setState(() {
        isLoading = false;
      });

    });


  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: ListView(
          children: [
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'StalisPos',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Sign In',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onChanged: (val) {
                        validateEmail(val);
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: _tooglePassowrdVisiable,
                            icon: Icon(Icons.security),
                          )),
                      obscureText: _passwordVisible,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                        tag: "login_btn",
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _loginUser,
                          child: Text(
                            "Login".toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }

  void _tooglePassowrdVisiable() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email can not be empty";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _errorMessage = "Invalid Email Address";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }
}
