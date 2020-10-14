import 'package:flutter/cupertino.dart';
import '../models/address.dart';


class AppData  extends ChangeNotifier {

  Address pickUpAddress;
  Address destinatinAddress;

  void updatePickUpAddress(Address pickup){
    pickUpAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination)
  {
      destinatinAddress = destination;
      notifyListeners();
  }
}