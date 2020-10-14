import 'package:cab_rider/screens/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './screens/mainpage.dart';
import './screens/loginpage.dart';
import './screens/registrationpage.dart';
import './dataprovoder/appdata.dart';

 Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   FirebaseApp app = await Firebase.initializeApp();
  runApp(CabRiderApp());
}

class CabRiderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>AppData(),
      
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'BoltRegular',
          primaryColor: Colors.blue
        ),
        //home: RegistrationPage(),
        initialRoute:  RegistrationPage.id,
        routes: {
          LoginPage.id : (context)=> LoginPage(),
          RegistrationPage.id : (context)=> RegistrationPage(),
          MainPage.id : (context)=>MainPage(),
        },
      ),
    );
  }
}
