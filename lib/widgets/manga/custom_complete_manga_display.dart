import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

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
  late MangaProgressController progressController;

  @override void initState(){
    super.initState();
    mangaData = widget.mangaData;
    progressController = MangaProgressController(context, mangaData);
  }

  @override void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.skeletonMode){
      if(mangaData.myListStatus == null && widget.displayType == MangaRowDisplayType.myUserList){
        return Container();
      }
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
                      child: generateCachedImage(mangaData.cover)
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
                                  height: getScreenHeight() * 0.005
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star, color: Colors.white, size: 20),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                          child: Text('${mangaData.mean ?? '-'}', style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600
                                          ))
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: getScreenWidth() * 0.025
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.table_chart, color: Colors.white, size: 18),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                          child: Text('#${mangaData.rank ?? '-'}', style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                          ))
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: getScreenWidth() * 0.025
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person_pin_rounded, color: Colors.white, size: 18.5),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                          child: Text('#${mangaData.popularity ?? '-'}', style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                          ))
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.005
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(getFormattedMangaMediaType(mangaData.mediaType), style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                    )),
                                    SizedBox(
                                      width: getScreenWidth() * 0.0075
                                    ),
                                    const Text('-'),
                                    SizedBox(
                                      width: getScreenWidth() * 0.0075
                                    ),
                                    mangaData.startDate != null ? parseDateToShortText(mangaData.startDate!) != null?
                                      Row(
                                        children: [
                                          Text(parseDateToShortText(mangaData.startDate!)!, style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                          )),
                                          SizedBox(
                                            width: getScreenWidth() * 0.0075
                                          ),
                                          const Text('-'),
                                          SizedBox(
                                            width: getScreenWidth() * 0.0075
                                          ),
                                        ]
                                      )
                                    : Container() : Container(),
                                    Text(getMangaStatus(mangaData.status), style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                    )),
                                  ],
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.01
                                ),
                                mangaData.myListStatus != null ?
                                  CustomButton(
                                    width: getScreenWidth() - animeDisplayCoverSize.width - defaultHorizontalPadding * 2, 
                                    height: getScreenHeight() * 0.05, 
                                    buttonColor: Colors.brown.withOpacity(0.4), 
                                    buttonText: 'Edit in list', 
                                    onTapped: () => progressController.openActionDrawer(), 
                                    setBorderRadius: true
                                  )
                                : 
                                  CustomButton(
                                    width: getScreenWidth() - animeDisplayCoverSize.width - defaultHorizontalPadding * 2, 
                                    height: getScreenHeight() * 0.05, 
                                    buttonColor: Colors.brown.withOpacity(0.4), 
                                    buttonText: 'Add to list', 
                                    onTapped: () => progressController.openActionDrawer(), 
                                    setBorderRadius: true
                                  )
                              ]
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    StringEllipsis.convertToEllipsis(mangaData.genres.map((e) => e.name).toList().join(', ')), 
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