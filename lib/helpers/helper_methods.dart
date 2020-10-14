import 'package:cab_rider/dataprovoder/appdata.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/address.dart';
import '../models/directionetials.dart';

class HelperMethod {
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
}
