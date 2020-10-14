import 'package:cab_rider/branb_colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/predictions.dart';

class PredictionTile extends StatelessWidget {

  final Prediction _prediction;
  PredictionTile(this._prediction);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10,),
        Row(
          children: [
            Icon(Icons.location_city, color: BrandColors.colorDimText,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(_prediction.mainText, overflow: TextOverflow.ellipsis, maxLines: 1,  style: TextStyle(fontSize: 16),)),
                SizedBox(height: 2,),
                Expanded(child: Text(_prediction.secondryText, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 12,color: BrandColors.colorDimText, ),)),
              ],
            )
          ],
        ),
        SizedBox(height: 10,),
      ],

    );
  }
}
