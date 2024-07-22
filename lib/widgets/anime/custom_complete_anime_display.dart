import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomUserListAnimeDisplay extends StatefulWidget {
  final AnimeDataClass animeData;
  final AnimeRowDisplayType displayType;
  final bool skeletonMode;

  const CustomUserListAnimeDisplay({
    super.key,
    required this.animeData,
    required this.displayType,
    required this.skeletonMode
  });

  @override
  State<CustomUserListAnimeDisplay> createState() => CustomUserListAnimeDisplayState();
}

class CustomUserListAnimeDisplayState extends State<CustomUserListAnimeDisplay>{
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
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding,
              vertical: defaultVerticalPadding
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: completeDisplayCoverSize.width,
                  height: completeDisplayCoverSize.height,
                  child: CachedImageWidget(imageClass: animeData.cover)
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
                                    StringEllipsis.convertToEllipsis(animeData.title), 
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(getFormattedAnimeMediaType(animeData.mediaType), style: TextStyle(
                                  fontSize: defaultTextFontSize * 0.8,
                                  fontWeight: FontWeight.w500
                                )),
                                const Text(' • '),
                                Text(getAnimeStatus(animeData.status), style: TextStyle(
                                  fontSize: defaultTextFontSize * 0.8,
                                  fontWeight: FontWeight.w500
                                )),
                              ],
                            ),
                            SizedBox(
                              height: getScreenHeight() * 0.01
                            ),
                          ]
                        ),
                        CustomButton(
                          width: getScreenWidth() - completeDisplayCoverSize.width - defaultHorizontalPadding * 2, 
                          height: getScreenHeight() * 0.06, 
                          buttonColor: Colors.brown.withOpacity(0.4), 
                          buttonText: 'Edit in list', 
                          onTapped: () => animeProgress.openActionDrawer(context, animeData), 
                          setBorderRadius: true
                        )
                      ]
                    )
                  )
                )
              ],
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