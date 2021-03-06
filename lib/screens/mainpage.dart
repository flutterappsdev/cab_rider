import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cab_rider/models/directionetials.dart';
import 'package:cab_rider/screens/searchpage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:cab_rider/branb_colour.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import '../widgets/brand_divider.dart';
import '../widgets/round_button.dart';
import '../constants/contants.dart';
import '../helpers/helper_methods.dart';
import '../dataprovoder/appdata.dart';
import '../models/address.dart';
import '../models/nearbydriver.dart';
import '../helpers/FireHelper.dart';

class MainPage extends StatefulWidget {
  static const String id = 'main';
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottompadding = 0;
  double bottomBoxHeight = Platform.isAndroid ? 260 : 280;
  double riderDetailsSheetHeight = 0;
  double cancelRideSheetHeight = 0;
  double requestingSheetHeight = 0;
  bool drawerOpen = true;

  LocationData currentLocation;
  LocationData destinationLocation;
  Location location;

  BitmapDescriptor nearbyIcon;

  List<LatLng> polyCoordinates = [];
  Set<Polyline> _polyLines = {};
  Set<Marker> _marker = {};
  Set<Circle> _circle = {};

  DirectionDetails tripDirectionDetials;

  DatabaseReference rederRef;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    location = Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      //setUpPositionLocator();
    });
    setUpPositionLocator();
    HelperMethod.getCurrentUserInfo(context);
    //startGeoFireListner();
  }

  void createMarker(){
    if(nearbyIcon == null){

      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2,2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, (Platform.isIOS)
          ? 'assetes/images/car_ios.png'
          : 'assetes/images/car_android.png'
      ).then((icon){
        nearbyIcon = icon;
      });
    }
  }

  void setUpPositionLocator() async {
    try {
      currentLocation = await location.getLocation();

      LatLng pos = LatLng(currentLocation.latitude, currentLocation.longitude);
      print("Laongtide ");
      CameraPosition cp = CameraPosition(target: pos, zoom: 14);
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

      String address = await HelperMethod.getLatLangAddres(pos, context);

      //print(address);
      //print(Provider.of<AppData>(context).pickUpAddress.placeAddress);


    } catch (e) {
      print("krishna $e");
    }

    startGeoFireListner();
  }

  Future<void> getDirections() async {
    try {
      var pickup = Provider.of<AppData>(context, listen: false).pickUpAddress;
      var destination =
          Provider.of<AppData>(context, listen: false).destinatinAddress;

      // print('pickup  ${pickup.longitude}');
      //print('destination  ${destination.longitude}');

      var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
      var destinationLatLng =
          LatLng(destination.latitude, destination.longitude);

      var thisDetails = await HelperMethod.getDirectionDetials(
          pickupLatLng, destinationLatLng);

      setState(() {
        tripDirectionDetials = thisDetails;
        drawerOpen = false;
      });

      //print(thisDetails.encodePoints.codeUnits.toString());

      PolylinePoints _polyLinePoint = PolylinePoints();
      List<PointLatLng> result =
          _polyLinePoint.decodePolyline(thisDetails.encodePoints);
      if (result.isNotEmpty) {
        result.forEach((PointLatLng element) {
          polyCoordinates.add(LatLng(element.latitude, element.longitude));
        });
      }
      //_polyLines.clear();
      setState(() {
        PolylineId id = PolylineId("poly");
        Polyline polyline = Polyline(
            polylineId: id,
            color: Color.fromARGB(255, 95, 109, 237),
            points: polyCoordinates,
            jointType: JointType.round,
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap);
        _polyLines.add(polyline);
      });

      LatLngBounds bounds;
      if (pickupLatLng.latitude > destinationLatLng.latitude &&
          pickupLatLng.longitude > destinationLatLng.longitude) {
        bounds =
            LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
      } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
        bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
        );
      } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
        bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
        );
      } else {
        bounds =
            LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
      }
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

      Marker pickupmarker = Marker(
        markerId: MarkerId('piclup'),
        position: pickupLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow:
            InfoWindow(title: pickup.placeAddress, snippet: 'My Location'),
      );

      Marker destinamarker = Marker(
        markerId: MarkerId('destim'),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: destination.placeAddress, snippet: ' Destination'),
      );

      setState(() {
        _marker.add(pickupmarker);
        _marker.add(destinamarker);
      });

      Circle pickupcircle = Circle(
          circleId: CircleId('pichup'),
          strokeColor: Colors.green,
          strokeWidth: 4,
          radius: 15,
          center: pickupLatLng,
          fillColor: BrandColors.colorGreen);

      Circle desticircle = Circle(
          circleId: CircleId('desti'),
          strokeColor: Colors.purple,
          strokeWidth: 4,
          radius: 15,
          center: pickupLatLng,
          fillColor: BrandColors.colorAccentPurple);

      setState(() {
        _circle.add(pickupcircle);
        _circle.add(desticircle);
      });
    } catch (e) {
      print('get derstion error $e');
    }
  }

  void showDetialsSheet() async {
    await getDirections();
    setState(() {
      bottomBoxHeight = 0;
      riderDetailsSheetHeight = Platform.isAndroid ? 255 : 275;
      mapBottompadding = Platform.isAndroid ? 280 : 270;
    });
  }

  void resetSearch() {
    setState(() {
      polyCoordinates.clear();
      _polyLines.clear();
      _marker.clear();
      _circle.clear();
      riderDetailsSheetHeight = 0;
      requestingSheetHeight=0;
      bottomBoxHeight = Platform.isAndroid ? 260 : 280;
      mapBottompadding = Platform.isAndroid ? 280 : 270;
      drawerOpen = true;
      setUpPositionLocator();
    });
  }

  void showRequestingSheet(){

    setState(() {
      riderDetailsSheetHeight = 0;
      requestingSheetHeight = Platform.isAndroid ? 195 : 220;
      mapBottompadding = Platform.isAndroid ? 280 : 270;
      drawerOpen = true;
    });
    createRiderRequest();
  }

  void createRiderRequest(){
    rederRef = FirebaseDatabase.instance.reference().child('riderRequest').push();

    var pickup = Provider.of<AppData>(context,listen: false).pickUpAddress;
    var desti = Provider.of<AppData>(context,listen: false).destinatinAddress;
    var userdata = Provider.of<AppData>(context,listen: false).userData;

    Map pickupMap = {
      'lat' : pickup.latitude,
      'lng' :pickup.longitude,
    };

    Map destMap = {
      'lat' : desti.latitude,
      'lng' : desti.longitude,
    };


    Map riderMap = {
     'crated_at' : DateTime.now().toString(),
      'rider_name': userdata.fullName,
      'rider_phone': userdata.phone,
      'pickup_address' : pickup.placeAddress,
      'destination_address' : desti.placeAddress,
      'location' : pickupMap,
      'destination' : destMap,
      'payment_method' : 'card',
      'drive_id' : 'waiting....'
    };
    print(riderMap);
    rederRef.set(riderMap);
  }

  void cancelRideRequest(){
    rederRef.remove();
    resetSearch();
  }

  void startGeoFireListner(){

    try {
      Geofire.initialize('DriversAvailable');
      Geofire.queryAtLocation(currentLocation.latitude, currentLocation.longitude,20).listen((map) {
        print('my drives location $map');
        if (map != null) {
          var callBack = map['callBack'];
          //latitude will be retrieved from map['latitude']
          //longitude will be retrieved from map['longitude']
          switch (callBack) {
            case Geofire.onKeyEntered:
              NearByDriver nearByDriver = NearByDriver();
              nearByDriver.key = map['key'];
              nearByDriver.latitude = map['latitude'];
              nearByDriver.longitude = map['longitude'];
              FireHelper.nearbyDriverList.add(nearByDriver);
              updateDriversonMap();
              break;
            case Geofire.onKeyExited:
              FireHelper.removeFromList(map['key']);
              updateDriversonMap();
              break;
            case Geofire.onKeyMoved:
            // Update your key's location
              NearByDriver nearByDriver = NearByDriver();
              nearByDriver.key = map['key'];
              nearByDriver.latitude = map['latitude'];
              nearByDriver.longitude = map['longitude'];
              FireHelper.updateNearByLocation (nearByDriver);
              updateDriversonMap();
              break;

            case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
              updateDriversonMap();
              print('length  ${FireHelper.nearbyDriverList.length}');
              break;
          }
        }
      });
    }
    catch(e) {
      print('geo fire error  $e');
    }
  }//end function geofire listner

  void updateDriversonMap(){
    setState(() {
      _marker.clear();
    });

    Set<Marker> tempMarker = Set<Marker>();

    for(NearByDriver drive in FireHelper.nearbyDriverList  ){
      LatLng driverPosition = LatLng(drive.latitude,drive.longitude);

      Random random = new Random();
      int randomNumber = random.nextInt(360);

      Marker thisMarker = Marker(
        markerId: MarkerId('d${drive.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: randomNumber.toDouble(),
      );

      tempMarker.add(thisMarker);
    }
      setState(() {
        _marker = tempMarker;
      });
  }


  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: _scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assetes/images/user_icon.png'),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Krishna',
                            style:
                                TextStyle(fontSize: 20, fontFamily: 'BoltSemi'),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text('View profile'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BrandDivider(),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text(
                  'Free Ride',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text(
                  'Payments',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text(
                  'Rider history',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text(
                  'Support',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(OMIcons.info),
                title: Text(
                  'About',
                  style: kDrawerItemStyle,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottompadding),
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            polylines: _polyLines,
            markers: _marker,
            circles: _circle,
            initialCameraPosition: MainPage._kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottompadding = Platform.isAndroid ? 280 : 270;
              });
              setUpPositionLocator();
            },
          ),

          //Menu item
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                drawerOpen
                    ? _scaffoldKey.currentState.openDrawer()
                    : resetSearch();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: .5,
                          spreadRadius: .5,
                          offset: Offset(
                            .7,
                            .7,
                          ))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    drawerOpen == true ? Icons.menu : Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          //Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              child: Container(
                height: mapBottompadding,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          spreadRadius: .8,
                          offset: Offset(.7, .7))
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Nice to see you',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'Where are you going',
                        style: TextStyle(fontSize: 18, fontFamily: 'BoltSemi'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage()),
                          );
                          //if(res == 'getdirection')
                          //{
                          showDetialsSheet();
                          //}
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 15,
                                    spreadRadius: .5,
                                    offset: Offset(.7, .7))
                              ]),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Search Destination')
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Row(
                        children: [
                          Icon(
                            OMIcons.home,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  Provider.of<AppData>(context).pickUpAddress !=
                                          null
                                      ? Provider.of<AppData>(context)
                                          .pickUpAddress
                                          .placeAddress
                                          .substring(0, 40)
                                      : 'Add Home'),
                              Text(
                                'Yor residence address',
                                style: TextStyle(
                                  color: BrandColors.colorDimText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      BrandDivider(),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Icon(
                            OMIcons.workOutline,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              Text(
                                'Yor Work address',
                                style: TextStyle(
                                  color: BrandColors.colorDimText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //Rider Detial Sheet
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      height: riderDetailsSheetHeight,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: .5,
                              blurRadius: .5,
                              offset: Offset(.7, .7),
                            )
                          ]),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Container(
                              width: double.infinity,
                              color: BrandColors.colorAccent1,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assetes/images/taxi.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TAXI',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'BoltSemi'),
                                        ),
                                        Text(
                                          tripDirectionDetials != null
                                              ? tripDirectionDetials
                                                  .distanceText
                                                  .toString()
                                              : "0",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'BoltSemi'),
                                        )
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      tripDirectionDetials != null
                                          ? 'Rs: ${HelperMethod.estimateFare(tripDirectionDetials).toString()}'
                                          : "0",
                                      style: TextStyle(
                                          fontSize: 15, fontFamily: 'BoltSemi'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.creditCard,
                                  size: 18,
                                  color: BrandColors.colorTextLight,
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  'CASH',
                                  style: TextStyle(
                                      fontSize: 15, fontFamily: 'BoltSemi'),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: BrandColors.colorTextLight,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: RoundButton(
                                'REQUEST CAB', BrandColors.colorGreen, () {
                                  showRequestingSheet();
                            }),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  height: requestingSheetHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: .5,
                          blurRadius: .5,
                          offset: Offset(.7, .7),
                        )
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting a ride ...',
                          waveColor: BrandColors.colorTextSemiLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BoldSemi'),
                          boxHeight: 40.0,
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1,color: BrandColors.colorLightGrayFair)
                        ),
                        child: GestureDetector(
                            onTap: (){
                              cancelRideRequest();
                            },
                            child: Icon(Icons.close,size: 25,)),
                      ),
                      GestureDetector(
                        onTap: (){
                          cancelRideRequest();
                        },
                          child: Text('Cancel Ride',style: TextStyle(fontSize: 13), ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
