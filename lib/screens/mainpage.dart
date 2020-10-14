import 'dart:async';
import 'dart:io';
import 'package:cab_rider/screens/searchpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:cab_rider/branb_colour.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../widgets/brand_divider.dart';
import '../constants/contants.dart';
import '../helpers/helper_methods.dart';
import '../dataprovoder/appdata.dart';
import '../models/address.dart';

class MainPage extends StatefulWidget {
  static const String id = 'main';
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottompadding = 0;
  double bottomBoxHeight = Platform.isAndroid ? 260 : 280;

  LocationData currentLocation;
  LocationData destinationLocation;
  Location location;

  List<LatLng> polyCoordinates = [];
  Set<Polyline> _polyLines = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    location = Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });
  }

  void setUpPositionLocator() async {
    try {
      currentLocation = await location.getLocation();

      LatLng pos = LatLng(currentLocation.latitude, currentLocation.longitude);
      print("Laongtide ");
      CameraPosition cp = CameraPosition(target: pos, zoom: 14);
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

      String address = await HelperMethod.getLatLangAddres(pos,context);

      //print(address);
      //print(Provider.of<AppData>(context).pickUpAddress.placeAddress);

    } catch (e) {
      print("krishna $e");
    }
  }

  Future<void> getDirections() async {

    try {
      var pickup = Provider.of<AppData>(context,listen: false).pickUpAddress;
      var destination = Provider.of<AppData>(context,listen: false).destinatinAddress;

     // print('pickup  ${pickup.longitude}');
      //print('destination  ${destination.longitude}');

      var pickupLatLng = LatLng(pickup.latitude,pickup.longitude);
      var destinationLatLng = LatLng(destination.latitude,destination.longitude);

      var thisDetails = await HelperMethod.getDirectionDetials(pickupLatLng, destinationLatLng);

      //print(thisDetails.encodePoints.codeUnits.toString());

      PolylinePoints _polyLinePoint = PolylinePoints();
      List<PointLatLng> result = _polyLinePoint.decodePolyline(thisDetails.encodePoints);
      if(result.isNotEmpty){
        result.forEach((PointLatLng element) {
          polyCoordinates.add(LatLng(element.latitude,element.longitude));
        });
      }
      //_polyLines.clear();
      setState(() {
        PolylineId id = PolylineId("poly");
        Polyline polyline = Polyline(
            polylineId: id, color: Color.fromARGB(255, 95, 109, 237), points: polyCoordinates,
            jointType: JointType.round,
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap
        );
        _polyLines.add(polyline);
      });

      LatLngBounds bounds;
      if(pickupLatLng.latitude > destinationLatLng.latitude && pickupLatLng.longitude > destinationLatLng.longitude)
        {
          bounds = LatLngBounds(southwest: destinationLatLng,northeast: pickupLatLng);
        }
      else if(pickupLatLng.longitude > destinationLatLng.longitude)
        {
          bounds = LatLngBounds(
            southwest: LatLng(pickupLatLng.latitude,destinationLatLng.longitude),
            northeast: LatLng(destinationLatLng.latitude,pickupLatLng.longitude),
          );
        }
      else if(pickupLatLng.latitude > destinationLatLng.latitude)
      {
        bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude,pickupLatLng.longitude),
          northeast: LatLng(pickupLatLng.latitude,destinationLatLng.longitude),
        );
      }
      else{
        bounds = LatLngBounds(southwest: pickupLatLng,northeast: destinationLatLng);
      }

      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    }
    catch(e)
    {
      print('get derstion error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            initialCameraPosition: MainPage._kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottompadding = Platform.isAndroid ? 280 : 270;
              });
              setUpPositionLocator();
              print('hello testing');
            },
          ),

          //Menu item
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState.openDrawer();
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
                    Icons.menu,
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
                        var res = await  Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchPage()),);
                        //if(res == 'getdirection')
                          //{
                            getDirections();
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
                            Text(Provider.of<AppData>(context).pickUpAddress!= null ? Provider.of<AppData>(context).pickUpAddress.placeAddress.substring(0,40) : 'Add Home'),
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
        ],
      ),
    );
  }
}
