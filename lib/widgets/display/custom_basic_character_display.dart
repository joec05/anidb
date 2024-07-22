import 'package:anidb/global_files.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        onTap: () => context.pushNamed('view-character-details', pathParameters: {'characterID': '${characterData.id}'}),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: basicDisplayWidgetSize.width,
            height: basicDisplayWidgetSize.height,
            margin: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding / 2
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: basicDisplayCoverSize.width,
                  height: basicDisplayCoverSize.height,
                  child: CachedImageWidget(imageClass: characterData.cover)
                ),
                SizedBox(
                  height: getScreenHeight() * 0.01
                ),
                Text(
                  characterData.name, 
                  style: TextStyle(
                    fontSize: defaultTextFontSize * 0.9,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
                )
              ],
            ),
          ),
        )
      );
    }else{
      return Card(
        margin: EdgeInsets.symmetric(
          horizontal: defaultHorizontalPadding / 2
        ),
        child: Center(
          child: SizedBox(
            width: basicDisplayCoverSize.width,
            height: basicDisplayCoverSize.height,
          ),
        )
      );
    }
  }

}