import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String tittle;
  final Color color;
  final Function onPress;

  RoundButton(this.tittle,this.color,this.onPress);


  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPress,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28)),
      color: color,
      textColor: Colors.white,
      child: Container(
        height: 50,
        child: Center(
          child: Text(
            tittle,
            style: TextStyle(
              fontFamily: 'BoltSemi',
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}