import 'package:anime_list_app/appdata/global_functions.dart';
import 'package:anime_list_app/class/character_voice_class.dart';
import 'package:anime_list_app/extensions/string_ellipsis.dart';
import 'package:anime_list_app/styles/app_styles.dart';
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
                  SizedBox(
                    width: animeGridDisplayCoverSize.width,
                    height: animeGridDisplayCoverSize.height,
                    child: generateCachedImage(voiceData.personCover)
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