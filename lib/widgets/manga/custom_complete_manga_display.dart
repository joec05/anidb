import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomUserListMangaDisplay extends StatefulWidget {
  final MangaDataClass mangaData;
  final MangaRowDisplayType displayType;
  final bool skeletonMode;

  const CustomUserListMangaDisplay({
    super.key,
    required this.mangaData,
    required this.displayType,
    required this.skeletonMode
  });

  @override
  State<CustomUserListMangaDisplay> createState() => CustomUserListMangaDisplayState();
}

class CustomUserListMangaDisplayState extends State<CustomUserListMangaDisplay>{
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
                      child: CachedImageWidget(imageClass: mangaData.cover)
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
                                        StringEllipsis.convertToEllipsis(mangaData.title), 
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
                                    Text(getFormattedAnimeMediaType(mangaData.mediaType), style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.8,
                                      fontWeight: FontWeight.w500
                                    )),
                                    const Text(' • '),
                                    Text(getMangaStatus(mangaData.status), style: TextStyle(
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
                            mangaData.myListStatus != null ?
                              CustomButton(
                                width: getScreenWidth() - completeDisplayCoverSize.width - defaultHorizontalPadding * 2, 
                                height: getScreenHeight() * 0.06, 
                                buttonColor: Colors.brown.withOpacity(0.4), 
                                buttonText: 'Edit in list', 
                                onTapped: () => mangaProgress.openActionDrawer(context, mangaData), 
                                setBorderRadius: true
                              )
                            : 
                              CustomButton(
                                width: getScreenWidth() - completeDisplayCoverSize.width - defaultHorizontalPadding * 2, 
                                height: getScreenHeight() * 0.06, 
                                buttonColor: Colors.brown.withOpacity(0.4), 
                                buttonText: 'Add to list', 
                                onTapped: () => mangaProgress.openActionDrawer(context, mangaData), 
                                setBorderRadius: true
                              )
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