import 'package:anime_list_app/view_character_details.dart';
import 'package:anime_list_app/appdata/global_functions.dart';
import 'package:anime_list_app/appdata/global_variables.dart';
import 'package:anime_list_app/class/character_data_class.dart';
import 'package:anime_list_app/extensions/string_ellipsis.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:anime_list_app/transition/navigation_transition.dart';
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
            NavigationTransition(
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
                      child: generateCachedImage(characterData.cover)
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