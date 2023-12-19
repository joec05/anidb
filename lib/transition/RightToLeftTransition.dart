import 'package:flutter/material.dart';

class SliderRightToLeftRoute extends PageRouteBuilder {
  final Widget page;

  SliderRightToLeftRoute({required this.page}) : super(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation
    ) {
      var begin = 0.0;
      var end = 1.0;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return ScaleTransition(
        scale: animation.drive(tween),
        child: page,
      );
    }
    
  );
}