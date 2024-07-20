import 'package:anime_list_app/global_files.dart';
import 'package:anime_list_app/styles/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomHomeFrontDisplay extends ConsumerStatefulWidget {
  final String label;
  final dynamic displayType;
  final List<dynamic> dataList;
  final bool isLoading;

  const CustomHomeFrontDisplay({
    super.key,
    required this.label,
    required this.displayType,
    required this.dataList,
    required this.isLoading
  });

  @override
  ConsumerState<CustomHomeFrontDisplay> createState() => CustomHomeFrontDisplayState();
}

class CustomHomeFrontDisplayState extends ConsumerState<CustomHomeFrontDisplay>{
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
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding * 0.25,
            vertical: defaultVerticalPadding,
          ),
          child: splashWidget(
            onTap: () => context.pushNamed(
              widget.displayType is AnimeBasicDisplayType ? 'view-more-anime'
              : widget.displayType is MangaBasicDisplayType ? 'view-more-manga'
              : 'view-more-characters',
              pathParameters: {'label': widget.label},
              extra: widget.displayType
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: defaultHorizontalPadding * 1.5,
                vertical: defaultVerticalPadding 
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const Icon(Icons.keyboard_arrow_right, size: 25)
                ],
              )
            )
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding / 2,
          ),
          height: basicDisplayWidgetSize.height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: getAnimeBasicDisplayFetchCount(),
            itemBuilder: (c, i){
              if(widget.isLoading){
                if(widget.displayType is AnimeBasicDisplayType){
                  return ShimmerWidget(
                    child: CustomBasicAnimeDisplay(
                      animeData: AnimeDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
                      showStats: false,
                      key: UniqueKey()
                    )
                  );
                }else if(widget.displayType is MangaBasicDisplayType){
                  return ShimmerWidget(
                    child: CustomBasicMangaDisplay(
                      mangaData: MangaDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
                      showStats: false,
                      key: UniqueKey()
                    )
                  );
                }else if(widget.displayType is CharacterBasicDisplayType){
                  return ShimmerWidget(
                    child: CustomBasicCharacterDisplay(
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
                  final AnimeDataClass animeData = widget.dataList[i];
                  return CustomBasicAnimeDisplay(
                    animeData: animeData,
                    showStats: false,
                    skeletonMode: false,
                    key: UniqueKey()
                  );
                }else if(widget.displayType is MangaBasicDisplayType){
                  final MangaDataClass mangaData = widget.dataList[i];
                  return CustomBasicMangaDisplay(
                    mangaData: mangaData,
                    showStats: false,
                    skeletonMode: false,
                    key: UniqueKey()
                  );
                }else if(widget.displayType is CharacterBasicDisplayType){
                  final CharacterDataClass characterData = widget.dataList[i];
                  return CustomBasicCharacterDisplay(
                    characterData: characterData,
                    showStats: false,
                    skeletonMode: false,
                    key: UniqueKey()
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
