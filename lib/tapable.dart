
import 'package:flutter/material.dart';

class Tapable extends StatelessWidget{

  final GestureTapCallback onTap;
  final GestureTapCallback onLongTap;
  final Widget child;
  final double radius;
  final StackFit fit;

  final Color overlayColor;

  const Tapable({
    this.overlayColor = Colors.transparent,
    this.child,
    this.onTap,
    this.radius = 4,
    this.fit = StackFit.loose,
    key, this.onLongTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(onTap == null && onLongTap == null){
      return child;
    }
    return Stack(
      fit: fit,
      children: <Widget>[
        child,
        Positioned.fill(
          child: Material(

            color: overlayColor,
            child: InkWell(
              focusColor: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              onTap: onTap,
              onLongPress: onLongTap,
            )
          )
        )
      ]
    );
  }
}
