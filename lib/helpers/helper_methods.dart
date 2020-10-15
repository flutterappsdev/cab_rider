import 'package:cab_rider/dataprovoder/appdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/address.dart';
import '../models/directionetials.dart';
import '../models/users.dart' as appusers;
import '../dataprovoder/appdata.dart';

class HelperMethod {

  static void getCurrentUserInfo(context) async{

    AppData appData =  AppData();
    try {
      var user = await FirebaseAuth.instance.currentUser;
      String userID = user.uid;
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('user/$userID');
      userRef.once().then((DataSnapshot snapshot) {
        if(snapshot.value!=null)
        {
          //appusers.User currentUserInfo = appusers.User.fromSnapshot(snapshot);
          appusers.User currentUserInfo = appusers.User();
          currentUserInfo.id = snapshot.key;
          currentUserInfo.fullName = snapshot.value['fullname'];
          currentUserInfo.phone = snapshot.value['phoene'];
          currentUserInfo.email = snapshot.value['eamil'];
          //   id = snapshot.key;
          //   fullName = snapshot.value['fullname'];
          //   phone = snapshot.value['phoene'];
          //   email = snapshot.value['eamil'];

          Provider.of<AppData>(context,listen: false).updateUserData(currentUserInfo);
          print('My full ame ${currentUserInfo.fullName}');

        }

      });
    }
    catch(e){
      print('from getting user $e');
    }

  }

  static Future<String> getLatLangAddres(LatLng pos, context) async {
    String placeAddress = '';
    ;
    final connResult = await Connectivity().checkConnectivity();
    if (connResult != ConnectivityResult.mobile &&
        connResult != ConnectivityResult.wifi) {
      return 'failed';
    }

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=AIzaSyBeGGR_m6OI1M9DSuPWq39cAmLpGtSZ4Vo';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      placeAddress = data['results'][0]['formatted_address'];

      try {
        Address pickUpAddress =
            Address("", pos.latitude, pos.longitude, '1', placeAddress);
        Provider.of<AppData>(context, listen: false)
            .updatePickUpAddress(pickUpAddress);
      } catch (e) {
        print('error $e');
      }

      return placeAddress;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  static Future<DirectionDetails> getDirectionDetials(LatLng startpostion, LatLng destination) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startpostion.latitude},${startpostion.longitude}&destination=${destination.latitude},${destination.longitude}&key=AIzaSyBeGGR_m6OI1M9DSuPWq39cAmLpGtSZ4Vo';
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        //print(data);
        DirectionDetails directionDetails = DirectionDetails();
        directionDetails.distanceText = data['routes'][0]['legs'][0]['distance']['text'];
        directionDetails.distanceVal =  data['routes'][0]['legs'][0]['distance']['value'];

        directionDetails.durationText = data['routes'][0]['legs'][0]['duration']['text'];
        directionDetails.durationVal = data['routes'][0]['legs'][0]['duration']['value'];

        directionDetails.encodePoints = data['routes'][0]['overview_polyline']['points'];

       // print('poly line ${data['routes']['0']['overview_polyline']['points'].toString()}');
        return directionDetails;
      }
    } catch (e) {
      print('error from get direction $e');

    }
  }

  static  int estimateFare(DirectionDetails direction){

    double basefare = 3;
    double distancefare = (direction.distanceVal/1000)*12;
    double timefare = (direction.durationVal/60)*2;

    double totalFare = basefare+ distancefare + timefare;

    return totalFare.truncate();

  }
}
