import 'package:cab_rider/screens/loginpage.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cab_rider/branb_colour.dart';
import 'package:connectivity/connectivity.dart';
import '../widgets/round_button.dart';
import '../widgets/progress_dialog.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> ScafoldKey = new GlobalKey<ScaffoldState>();

  final auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  Future<void> register() async {

    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext bulidcontext)=>ProgressDialog('Registering you...')
    );

    UserCredential authResult;
    try {
      authResult = await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } catch (ex) {
      Navigator.pop(context);
      showSnackBar(ex.toString());
    }
    if (authResult != null) {
      print('Success');

      final DatabaseReference ref = FirebaseDatabase.instance.reference().child('user/${authResult.user.uid}');
      Map user = {
        'fullname': fullNameController.text,
        'eamil' : emailController.text,
        'phoene' : phoneController.text,
      };
      ref.set(user);
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);

    }
  }

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

  @override
  Widget build(BuildContext context) {
    void onRegister() {}

    return Scaffold(
      key: ScafoldKey,
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
                'Create a Riders Account',
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
                      controller: fullNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintStyle:
                              TextStyle(fontSize: 10, color: Colors.grey)),
                      style: TextStyle(fontFamily: 'BoltRegular', fontSize: 14),
                    ), //Full NAme
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email address',
                          hintStyle:
                              TextStyle(fontSize: 10, color: Colors.grey)),
                      style: TextStyle(fontFamily: 'BoltRegular', fontSize: 14),
                    ), //Email Addrsss
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Mobile number',
                          hintStyle:
                              TextStyle(fontSize: 10, color: Colors.grey)),
                      style: TextStyle(fontFamily: 'BoltRegular', fontSize: 14),
                    ), //Mobile no
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
                    RoundButton('REGISTER', BrandColors.colorGreen, () async{

                     final connResult =  await Connectivity().checkConnectivity();
                     if(connResult!= ConnectivityResult.mobile && connResult!= ConnectivityResult.wifi)
                       {
                         showSnackBar('Please check you internet connection');
                         return;
                       }


                      if (fullNameController.text.length < 3) {
                        showSnackBar('Please enter a valid name');
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

                      register();
                    }),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginPage.id, (route) => false);
                },
                child: Text('Already have an Rides account,Login.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
