import 'dart:convert';
import 'package:cab_rider/branb_colour.dart';
import 'package:cab_rider/models/address.dart';
import 'package:cab_rider/models/predictions.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../dataprovoder/appdata.dart';
import '../widgets/predictiontile.dart';
import '../models/predictions.dart';
import '../widgets/brand_divider.dart';
import '../widgets/progress_dialog.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickuptextController = TextEditingController();
  var destitextController = TextEditingController();

  var focusDestination = FocusNode();
  bool focused = false;
  void setfocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];
  void searchPlace(String placeName) async {
    //print(placeName);
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyBeGGR_m6OI1M9DSuPWq39cAmLpGtSZ4Vo&sessiontoken=1234567890&country=in';
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        //print(data);
        // if(data["status"]=="OK")
        // {
        //print(data);
        var predictioncJson = data["predictions"];
        var thisList = (predictioncJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();

        setState(() {
          destinationPredictionList = thisList;
          // print(destinationPredictionList);
        });
        //}

      } else {}
    }
  }

  void getPlacesDetials(String placeID) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=AIzaSyBeGGR_m6OI1M9DSuPWq39cAmLpGtSZ4Vo';
    //print('placeid  $placeID');
    try {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ProgressDialog('Please wait...'),
      );

      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Navigator.pop(context);
        print(data);
        Address thisAddress = Address(
            data['result']['formatted_address'],
            data['result']['geometry']['location']['lat'],
            data['result']['geometry']['location']['lng'],
            placeID,
            "");

        Provider.of<AppData>(context, listen: false)
            .updateDestinationAddress(thisAddress);
        //   print('Addresssss ${thisAddress.placeName}');

        Navigator.pop(context, 'getdirection');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    String address = Provider.of<AppData>(context).pickUpAddress.placeAddress;
    pickuptextController.text = address;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: .5,
                    spreadRadius: .5,
                    offset: Offset(.7, .7),
                  )
                ]),
                child: Padding(
                  padding: EdgeInsets.only(top: 5, left: 20),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back),
                          ),
                          Center(
                            child: Text(
                              'Set Destination',
                              style: TextStyle(fontSize: 25),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assetes/images/pickicon.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: BrandColors.colorLightGrayFair),
                              child: TextField(
                                controller: pickuptextController,
                                decoration: InputDecoration(
                                    hintText: 'Pickup location',
                                    fillColor: BrandColors.colorLightGrayFair,
                                    filled: true,
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 8, bottom: 8)),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assetes/images/desticon.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: BrandColors.colorLightGrayFair),
                              child: TextField(
                                onChanged: (value) {
                                  searchPlace(value);
                                },
                                controller: destitextController,
                                focusNode: focusDestination,
                                decoration: InputDecoration(
                                    hintText: 'Where to?',
                                    fillColor: BrandColors.colorLightGrayFair,
                                    filled: true,
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 8, bottom: 8)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              (destinationPredictionList.length > 0)
                  ? Container(
                      height: 400,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: ListView.separated(
                          padding: EdgeInsets.all(8),
                          itemBuilder: (context, index) => Container(
                            child: FlatButton(
                              onPressed: () {
                                getPlacesDetials(
                                    destinationPredictionList[index].placeId);
                              },
                              child: Row(
                                children: [
                                  Icon(OMIcons.locationOn),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          destinationPredictionList[index]
                                              .mainText,
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          destinationPredictionList[index]
                                              .secondryText,
                                          overflow: TextOverflow.clip,
                                          maxLines: 2,
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          separatorBuilder: (context, index) => BrandDivider(),
                          itemCount: destinationPredictionList.length,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
