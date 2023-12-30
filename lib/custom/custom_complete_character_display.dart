import 'package:anime_list_app/view_character_details.dart';
import 'package:anime_list_app/appdata/global_functions.dart';
import 'package:anime_list_app/appdata/global_variables.dart';
import 'package:anime_list_app/class/character_data_class.dart';
import 'package:anime_list_app/extensions/string_ellipsis.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:anime_list_app/transition/navigation_transition.dart';
import 'package:flutter/material.dart';

class CustomRowCharacterDisplay extends StatefulWidget {
  final CharacterDataClass characterData;
  final bool skeletonMode;

  const CustomRowCharacterDisplay({
    super.key,
    required this.characterData,
    required this.skeletonMode
  });

  @override
  State<CustomRowCharacterDisplay> createState() => CustomRowCharacterDisplayState();
}

class CustomRowCharacterDisplayState extends State<CustomRowCharacterDisplay>{
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
            padding: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding,
              vertical: defaultVerticalPadding
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: animeDisplayCoverSize.width,
                      height: animeDisplayCoverSize.height,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Colors.grey.withOpacity(0.6)
                        ),
                      ),
                      child: generateCachedImage(characterData.cover)
                    ),
                    SizedBox(
                      width: getScreenWidth() * 0.025
                    ),
                    Flexible(
                      child: SizedBox(
                        width: getScreenWidth() - animeDisplayCoverSize.width - defaultHorizontalPadding * 2,
                        height: animeDisplayCoverSize.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        StringEllipsis.convertToEllipsis(characterData.name), 
                                        style: TextStyle(
                                          fontSize: defaultTextFontSize * 0.975,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis
                                      )
                                    )
                                  ]
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.005
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.white, size: 18),
                                    SizedBox(
                                      width: getScreenWidth() * 0.004,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, 0, 0, 0),
                                      child: Text(getShortenedNumbers(characterData.favouritedCount), style: TextStyle(
                                        fontSize: defaultTextFontSize * 0.9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600
                                      ))
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.005
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        characterData.kanjiName ?? 'Unspecified kanji name', 
                                        style: TextStyle(
                                          fontSize: defaultTextFontSize * 0.9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                        ),
                                        maxLines: 1,
                                      )
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.01
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        StringEllipsis.convertToEllipsis(characterData.about ?? ''), 
                                        style: TextStyle(
                                          fontSize: defaultTextFontSize * 0.85,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis
                                      )
                                    )
                                  ]
                                ),
                              ]
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    StringEllipsis.convertToEllipsis(characterData.nicknames.join(', ')), 
                                    style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.85,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis
                                  )
                                )
                              ]
                            ),
                          ]
                        )
                      )
                    )
                  ],
                ),
              ]
            )
          ),
        )
      );
    }else{
      return Card(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding,
              vertical: defaultVerticalPadding
            ),
            width: animeDisplayCoverSize.width,
            height: animeDisplayCoverSize.height,
          ),
        )
      ); 
    }
  }
}