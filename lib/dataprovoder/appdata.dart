import 'package:flutter/cupertino.dart';
import '../models/address.dart';
import '../models/users.dart';


class AppData  extends ChangeNotifier {

  Address pickUpAddress;
  Address destinatinAddress;
  User userData;

  void updatePickUpAddress(Address pickup){
    pickUpAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination)
  {
      destinatinAddress = destination;
      notifyListeners();
  }

  void updateUserData(User userdata){
    userData = userdata;
    notifyListeners();
  }
}