import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class CustomBasicMangaDisplay extends StatefulWidget {
  final MangaDataClass mangaData;
  final bool showStats;
  final bool skeletonMode;

  const CustomBasicMangaDisplay({
    super.key,
    required this.mangaData,
    required this.showStats,
    required this.skeletonMode
  });

  @override
  State<CustomBasicMangaDisplay> createState() => CustomBasicMangaDisplayState();
}

class CustomBasicMangaDisplayState extends State<CustomBasicMangaDisplay>{
  late MangaDataClass mangaData;

  @override void initState(){
    super.initState();
    mangaData = widget.mangaData;
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
              page: ViewMangaDetails(
                mangaID: mangaData.id
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
                      child: generateCachedImage(mangaData.cover)
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
                                  child: Text('${mangaData.mean ?? '-'}', style: TextStyle(
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
                                  child: Text('#${mangaData.rank ?? '-'}', style: TextStyle(
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
                                  child: Text('#${mangaData.popularity ?? '-'}', style: TextStyle(
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
                  StringEllipsis.convertToEllipsis(mangaData.title), 
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