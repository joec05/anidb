// ignore_for_file: library_private_types_in_public_api

import 'package:anime_list_app/appdata/global_library.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final double width;
  final double height;
  final Color buttonColor;
  final String buttonText;
  final VoidCallback? onTapped;
  final bool setBorderRadius;

  const CustomButton({super.key, 
    required this.width, required this.height, required this.buttonColor, required this.buttonText,
    required this.onTapped, required this.setBorderRadius
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {

  @override void initState(){
    super.initState();
  }

  @override void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width, height: widget.height,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.onTapped == null ? Colors.white.withOpacity(0.5) : widget.buttonColor,
          borderRadius: widget.setBorderRadius ? const BorderRadius.all(Radius.circular(5)) : BorderRadius.zero
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashFactory: InkRipple.splashFactory,
            onTap: (){
              Future.delayed(Duration(milliseconds: navigatorDelayTime), (){}).then((value) => widget.onTapped!());
            },
            child: Center(
              child: Text(widget.buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
            )
          ),
        ),
      )
    );
  }

}