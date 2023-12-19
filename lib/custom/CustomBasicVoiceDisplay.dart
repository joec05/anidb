// ignore_for_file: use_build_context_synchronously
import 'package:anime_list_app/appdata/GlobalFunctions.dart';
import 'package:anime_list_app/class/CharacterVoiceClass.dart';
import 'package:anime_list_app/extensions/StringEllipsis.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:flutter/material.dart';

class CustomBasicVoiceDisplay extends StatefulWidget {
  final CharacterVoiceClass voiceData;

  const CustomBasicVoiceDisplay({
    super.key,
    required this.voiceData,
  });

  @override
  State<CustomBasicVoiceDisplay> createState() => CustomBasicVoiceDisplayState();
}

class CustomBasicVoiceDisplayState extends State<CustomBasicVoiceDisplay>{
  late CharacterVoiceClass voiceData;

  @override void initState(){
    super.initState();
    voiceData = widget.voiceData;
  }

  @override void dispose(){
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Center(
        child: Container(
          width: animeGridDisplayWidgetSize.width,
          height: animeGridDisplayWidgetSize.height,
          margin: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding / 2
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: animeGridDisplayCoverSize.width,
                    height: animeGridDisplayCoverSize.height,
                    child: Image.network(voiceData.personCover.large, fit: BoxFit.cover)
                  )
                ],
              ),
              SizedBox(
                height: getScreenHeight() * 0.0025
              ),
              Text(
                StringEllipsis.convertToEllipsis(voiceData.personTitle), 
                style: TextStyle(
                  fontSize: defaultTextFontSize * 0.9,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis
              ),
              SizedBox(
                height: getScreenHeight() * 0.001
              ),
              Text(
                StringEllipsis.convertToEllipsis(voiceData.language), 
                style: TextStyle(
                  fontSize: defaultTextFontSize * 0.85,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis
              )
            ],
          ),
        ),
      )
    );
  }

}