// ignore_for_file: use_build_context_synchronously
import 'package:anime_list_app/ViewCharacterDetails.dart';
import 'package:anime_list_app/appdata/GlobalFunctions.dart';
import 'package:anime_list_app/appdata/GlobalVariables.dart';
import 'package:anime_list_app/class/CharacterDataClass.dart';
import 'package:anime_list_app/extensions/StringEllipsis.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:anime_list_app/transition/RightToLeftTransition.dart';
import 'package:flutter/material.dart';

class CustomBasicCharacterDisplay extends StatefulWidget {
  final CharacterDataClass characterData;
  final bool showStats;
  final bool skeletonMode;

  const CustomBasicCharacterDisplay({
    super.key,
    required this.characterData,
    required this.showStats,
    required this.skeletonMode
  });

  @override
  State<CustomBasicCharacterDisplay> createState() => CustomBasicCharacterDisplayState();
}

class CustomBasicCharacterDisplayState extends State<CustomBasicCharacterDisplay>{
  late CharacterDataClass characterData;

  @override void initState(){
    super.initState();
    characterData = widget.characterData;
  }

  @override void dispose(){
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if(!widget.skeletonMode){
      return GestureDetector(
        onTap: (){
          runDelay(() => Navigator.push(
            context,
            SliderRightToLeftRoute(
              page: ViewCharacterDetails(
                characterID: characterData.id
              )
            )
          ), navigatorDelayTime);
        },
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
                      child: characterData.cover.large != null ? Image.network(characterData.cover.large!, fit: BoxFit.cover) : Image.asset("assets/images/anime-no-image.png", fit: BoxFit.cover)
                    ),
                    widget.showStats ?
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: defaultVerticalPadding / 2
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.favorite, color: Colors.white, size: 14),
                                SizedBox(
                                  width: getScreenWidth() * 0.004,
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                  child: Text(getShortenedNumbers(characterData.favouritedCount), style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                )
                              ],
                            ),
                          ],
                        )
                      )
                    : Container()
                  ],
                ),
                SizedBox(
                  height: getScreenHeight() * 0.0025
                ),
                Text(
                  StringEllipsis.convertToEllipsis(characterData.name), 
                  style: TextStyle(
                    fontSize: defaultTextFontSize * 0.9,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                )
              ],
            ),
          ),
        )
      );
    }else{
      return Card(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding / 2
            ),
            width: animeGridDisplayWidgetSize.width,
            height: animeGridDisplayWidgetSize.height,
          ),
        )
      );
    }
  }

}