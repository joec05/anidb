import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        onTap: () => context.pushNamed('view-manga-details', pathParameters: {'mangaID': '${mangaData.id}'}),
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
                  child: CachedImageWidget(imageClass: mangaData.cover)
                ),
                SizedBox(
                  height: getScreenHeight() * 0.01
                ),
                Text(
                  mangaData.title, 
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