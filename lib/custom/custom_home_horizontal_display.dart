import 'package:anime_list_app/view_anime_basic_display.dart';
import 'package:anime_list_app/view_character_basic_display.dart';
import 'package:anime_list_app/view_manga_basic_display.dart';
import 'package:anime_list_app/appdata/global_enums.dart';
import 'package:anime_list_app/appdata/global_functions.dart';
import 'package:anime_list_app/appdata/global_variables.dart';
import 'package:anime_list_app/class/anime_data_class.dart';
import 'package:anime_list_app/class/character_data_class.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/custom/custom_basic_anime_display.dart';
import 'package:anime_list_app/custom/custom_basic_character_display.dart';
import 'package:anime_list_app/custom/custom_basic_manga_display.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:anime_list_app/transition/navigation_transition.dart';
import 'package:flutter/material.dart';

class CustomHomeFrontDisplay extends StatefulWidget {
  final String label;
  final dynamic displayType;
  final List<int> dataList;
  final bool isLoading;

  const CustomHomeFrontDisplay({
    super.key,
    required this.label,
    required this.displayType,
    required this.dataList,
    required this.isLoading
  });

  @override
  State<CustomHomeFrontDisplay> createState() => CustomHomeFrontDisplayState();
}

class CustomHomeFrontDisplayState extends State<CustomHomeFrontDisplay>{
  late CharacterDataClass characterData;

  @override void initState(){
    super.initState();
  }

  @override void dispose(){
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            defaultHorizontalPadding * 1.75,
            defaultVerticalPadding * 3,
            defaultHorizontalPadding * 2.5,
            defaultVerticalPadding * 2
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
              runDelay(() => Navigator.push(
                context,
                NavigationTransition(
                  page: widget.displayType is AnimeBasicDisplayType ?
                    ViewAnimeBasicDisplay(
                      label: widget.label, 
                      displayType: widget.displayType
                    )
                  : widget.displayType is MangaBasicDisplayType ?
                    ViewMangaBasicDisplay(
                      label: widget.label, 
                      displayType: widget.displayType
                    )
                  :
                    ViewCharacterBasicDisplay(
                      label: widget.label, 
                      displayType: widget.displayType
                    )
                )
              ), navigatorDelayTime);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: defaultTextFontSize * 1.25,
                    fontWeight: FontWeight.bold
                  )
                ),
                const Icon(Icons.keyboard_arrow_right, size: 25)
              ],
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding / 2,
          ),
          height: animeGridDisplayWidgetSize.height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: getAnimeBasicDisplayFetchCount(),
            itemBuilder: (c, i){
              if(widget.isLoading){
                if(widget.displayType is AnimeBasicDisplayType){
                  return shimmerSkeletonWidget(
                    CustomBasicAnimeDisplay(
                      animeData: AnimeDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
                      showStats: false,
                      key: UniqueKey()
                    )
                  );
                }else if(widget.displayType is MangaBasicDisplayType){
                  return shimmerSkeletonWidget(
                    CustomBasicMangaDisplay(
                      mangaData: MangaDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
                      showStats: false,
                      key: UniqueKey()
                    )
                  );
                }else if(widget.displayType is CharacterBasicDisplayType){
                  return shimmerSkeletonWidget(
                    CustomBasicCharacterDisplay(
                      characterData: CharacterDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
                      showStats: false,
                      key: UniqueKey()
                    )
                  );
                }
              }
              if(i < widget.dataList.length){
                if(widget.displayType is AnimeBasicDisplayType){
                  if(appStateClass.globalAnimeData[widget.dataList[i]] == null){
                    return Container();
                  }
                  return ValueListenableBuilder(
                    valueListenable: appStateClass.globalAnimeData[widget.dataList[i]]!.notifier, 
                    builder: (context, animeData, child){
                      return CustomBasicAnimeDisplay(
                        animeData: animeData,
                        showStats: true,
                        skeletonMode: false,
                        key: UniqueKey()
                      );
                    }
                  );
                }else if(widget.displayType is MangaBasicDisplayType){
                  if(appStateClass.globalMangaData[widget.dataList[i]] == null){
                    return Container();
                  }
                  return ValueListenableBuilder(
                    valueListenable: appStateClass.globalMangaData[widget.dataList[i]]!.notifier, 
                    builder: (context, mangaData, child){
                      return CustomBasicMangaDisplay(
                        mangaData: mangaData,
                        showStats: true,
                        skeletonMode: false,
                        key: UniqueKey()
                      );
                    }
                  );
                }else if(widget.displayType is CharacterBasicDisplayType){
                  if(appStateClass.globalCharacterData[widget.dataList[i]] == null){
                    return Container();
                  }
                  return ValueListenableBuilder(
                    valueListenable: appStateClass.globalCharacterData[widget.dataList[i]]!.notifier, 
                    builder: (context, characterData, child){
                      return CustomBasicCharacterDisplay(
                        characterData: characterData,
                        showStats: true,
                        skeletonMode: false,
                        key: UniqueKey()
                      );
                    }
                  );
                }
              }
              return Container();
            },
          )
        )
      ]
    );
  }

}
