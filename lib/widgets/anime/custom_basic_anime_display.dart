import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        onTap: () => context.pushNamed('view-anime-details', pathParameters: {'animeID': '${animeData.id}'}),
        child: Center(
          child: Container(
            width: animeGridDisplayWidgetSize.width,
            height: animeGridDisplayWidgetSize.height,
            margin: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding / 2
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: animeGridDisplayCoverSize.width,
                  height: animeGridDisplayCoverSize.height,
                  child: generateCachedImage(animeData.cover)
                ),
                SizedBox(
                  height: getScreenHeight() * 0.01
                ),
                Text(
                  animeData.title, 
                  style: TextStyle(
                    fontSize: defaultTextFontSize * 0.85,
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