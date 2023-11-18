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
  final _form = GlobalKey<FormState>();
  var _isLoading = false;


  Future<void> _login() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    await Provider.of<UserLogin>(context, listen: false).authenticateUser(emailController.text, passwordController.text).then((authResponse) {
      if (authResponse['ResultCode'] == 1500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authResponse['message']), duration: const Duration(seconds: 3), backgroundColor: Colors.red),
        );
      }

      Navigator.pushNamedAndRemoveUntil(
          context, '/start', (route) => false);

      setState(() {
        _isLoading = false;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Center(
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
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Password.';
                          }
                          return null;
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
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Password.';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.green),
                            ),
                          ),
                          onPressed: _login,
                          child: Text('Sign in'),
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
