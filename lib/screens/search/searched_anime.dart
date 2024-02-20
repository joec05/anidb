import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class SearchedAnimesWidget extends StatelessWidget {
  final String searchedText;
  final BuildContext absorberContext;

  const SearchedAnimesWidget({
    super.key,
    required this.searchedText,
    required this.absorberContext
  });

  @override
  Widget build(BuildContext context) {
    return _SearchedAnimesWidgetStateful(
      searchedText: searchedText,
      absorberContext: absorberContext
    );
  }
}

class _SearchedAnimesWidgetStateful extends StatefulWidget {
  final String searchedText;
  final BuildContext absorberContext;
  
  const _SearchedAnimesWidgetStateful({
    required this.searchedText,
    required this.absorberContext
  });

  @override
  State<_SearchedAnimesWidgetStateful> createState() => _SearchedAnimesWidgetStatefulState();
}

class _SearchedAnimesWidgetStatefulState extends State<_SearchedAnimesWidgetStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late SearchedAnimeController controller;

  @override void initState(){
    super.initState();
    controller = SearchedAnimeController(context, widget.searchedText);
    controller.initializeController();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(widget.absorberContext)
        ),
        ValueListenableBuilder(
          valueListenable: controller.isLoading,
          builder: (context, isLoadingValue, child) {
            if(isLoadingValue) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: skeletonLoadingDefaultLimit, 
                  (c, i) {
                    return shimmerSkeletonWidget(
                      CustomUserListAnimeDisplay(
                        animeData: AnimeDataClass.fetchNewInstance(-1),
                        displayType: AnimeRowDisplayType.search,
                        skeletonMode: true,
                        key: UniqueKey()
                      )
                    );
                  }
                )
              );
            }

            return ValueListenableBuilder(
              valueListenable: controller.animesList,
              builder: (context, animesList, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: animesList.length, 
                    (c, i) {
                      if(appStateRepo.globalAnimeData[animesList[i]] != null){
                        return ValueListenableBuilder(
                          valueListenable: appStateRepo.globalAnimeData[animesList[i]]!.notifier, 
                          builder: (context, animeData, child){
                            return CustomUserListAnimeDisplay(
                              animeData: animeData,
                              displayType: AnimeRowDisplayType.search,
                              skeletonMode: false,
                              key: UniqueKey()
                            );
                          }
                        );
                      }
                      return Text('${animesList[i]}');
                    }
                  )
                );
              }
            );
          }
        )
      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}