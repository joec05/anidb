import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        onTap: () => context.pushNamed('view-character-details', pathParameters: {'characterID': '${characterData.id}'}),
        behavior: HitTestBehavior.opaque,
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
                    SizedBox(
                      width: completeDisplayCoverSize.width,
                      height: completeDisplayCoverSize.height,
                      child: CachedImageWidget(imageClass: characterData.cover)
                    ),
                    SizedBox(
                      width: getScreenWidth() * 0.025
                    ),
                    Flexible(
                      child: Container(
                        width: getScreenWidth() - completeDisplayCoverSize.width - defaultHorizontalPadding * 2,
                        height: completeDisplayCoverSize.height,
                        padding: EdgeInsets.symmetric(
                          vertical: defaultVerticalPadding * 2.5
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  height: getScreenHeight() * 0.01
                                ),
                                Text(characterData.about ?? 'No description provided', maxLines: 3, style: TextStyle(
                                  fontSize: defaultTextFontSize * 0.8,
                                  fontWeight: FontWeight.w500
                                )),
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
            width: completeDisplayCoverSize.width,
            height: completeDisplayCoverSize.height,
          ),
        )
      ); 
    }
  }
}