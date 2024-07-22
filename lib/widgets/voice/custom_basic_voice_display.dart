import 'package:anidb_app/global_files.dart';
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
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: basicDisplayWidgetSize.width,
          height: basicDisplayWidgetSize.height,
          margin: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding / 2
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: basicDisplayCoverSize.width,
                    height: basicDisplayCoverSize.height,
                    child: CachedImageWidget(imageClass: voiceData.personCover)
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