import 'package:cab_rider/screens/mainpage.dart';
import 'package:cab_rider/screens/registrationpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cab_rider/branb_colour.dart';
import '../screens/registrationpage.dart';
import '../widgets/round_button.dart';
import '../widgets/progress_dialog.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> ScafoldKey = new GlobalKey<ScaffoldState>();

  final auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void showSnackBar(String tittle) {
    final snackBar = SnackBar(
      content: Text(
        tittle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    ScafoldKey.currentState.showSnackBar(snackBar);
  }

  void login() async {

    showDialog(context: context,
     barrierDismissible: false,
     builder: (BuildContext blidcontext)=>ProgressDialog('Logging in you...')
    );
    final _auth = FirebaseAuth.instance;
    UserCredential user;
    try {
       user = await _auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    }
    catch (ex) {
      Navigator.pop(context);
      showSnackBar(ex.toString());
    }

    if(user!=null){

      final DatabaseReference ref = FirebaseDatabase.instance.reference().child('user/${user.user.uid}');
      ref.once().then((DataSnapshot db)
      {
        Navigator.pushNamedAndRemoveUntil(
            context, MainPage.id, (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 70,
              ),
              Center(
                child: Image(
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                  image: AssetImage('assetes/images/logo.png'),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'Sign In as rider',
                style: TextStyle(
                  fontFamily: 'BoltSemi',
                  fontSize: 25,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email address',
                          hintStyle:
                              TextStyle(fontSize: 10, color: Colors.grey)),
                      style: TextStyle(fontFamily: 'BoltRegular', fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    RoundButton('LOGIN', BrandColors.colorGreen, () async {
                      final connResult =
                          await Connectivity().checkConnectivity();
                      if (connResult != ConnectivityResult.mobile &&
                          connResult != ConnectivityResult.wifi) {
                        showSnackBar('Please check you internet connection');
                        return;
                      }

                      if (!emailController.text.contains('@')) {
                        showSnackBar('Please enter a valid email address');
                        return;
                      }

                      if (passwordController.text.length < 8) {
                        showSnackBar(
                            'Please enter password of atleast eight charchater');
                        return;
                      }
                      login();
                    }),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RegistrationPage.id, (route) => false);
                },
                child: Text('Don\'t have an account,sign up here.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
