// ignore_for_file: use_build_context_synchronously
import 'package:anime_list_app/ViewAnimeDetails.dart';
import 'package:anime_list_app/appdata/GlobalFunctions.dart';
import 'package:anime_list_app/appdata/GlobalVariables.dart';
import 'package:anime_list_app/class/AnimeDataClass.dart';
import 'package:anime_list_app/extensions/StringEllipsis.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:anime_list_app/transition/RightToLeftTransition.dart';
import 'package:flutter/material.dart';

class CustomBasicAnimeDisplay extends StatefulWidget {
  final AnimeDataClass animeData;
  final bool showStats;
  final bool skeletonMode;

  const CustomBasicAnimeDisplay({
    super.key,
    required this.animeData,
    required this.showStats,
    required this.skeletonMode
  });

  @override
  State<CustomBasicAnimeDisplay> createState() => CustomBasicAnimeDisplayState();
}

class CustomBasicAnimeDisplayState extends State<CustomBasicAnimeDisplay>{
  late AnimeDataClass animeData;

  @override void initState(){
    super.initState();
    animeData = widget.animeData;
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
              page: ViewAnimeDetails(
                animeID: animeData.id
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
                      child: animeData.cover != null ? Image.network(animeData.cover!.large, fit: BoxFit.cover) : Image.asset("assets/images/anime-no-image.png", fit: BoxFit.cover)
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 14),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                  child: Text('${animeData.mean ?? '-'}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.table_chart, color: Colors.white, size: 14),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                  child: Text('#${animeData.rank ?? '-'}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_pin_rounded, color: Colors.white, size: 14.5),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                  child: Text('#${animeData.popularity ?? '-'}', style: TextStyle(
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
                  StringEllipsis.convertToEllipsis(animeData.title), 
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