import '../models/nearbydriver.dart';

class FireHelper {

  static List<NearByDriver>  nearbyDriverList = [];

  static void removeFromList(String key){
    int index= nearbyDriverList.indexWhere((element) => element.key==key);
    nearbyDriverList.removeAt(index);

  }

  static void updateNearByLocation(NearByDriver nearDriver){
    int index= nearbyDriverList.indexWhere((element) => element.key==nearDriver.key);
    nearbyDriverList[index].latitude = nearDriver.latitude;
    nearbyDriverList[index].longitude = nearDriver.longitude;


  }

}