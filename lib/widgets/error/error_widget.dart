import 'package:anidb_app/constants/ui/screen_size/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DisplayErrorWidget extends StatelessWidget {

  final String displayText;

  const DisplayErrorWidget({super.key, required this.displayText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              const Icon(FontAwesomeIcons.triangleExclamation, size: 45),
              SizedBox(height: getScreenHeight() * 0.025),
              Text(displayText)
            ]
          ),
        ),
      ),
    );
  }
}