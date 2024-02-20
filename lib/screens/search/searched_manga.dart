import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class SearchedMangasWidget extends StatelessWidget {
  final String searchedText;
  final BuildContext absorberContext;

  const SearchedMangasWidget({
    super.key,
    required this.searchedText,
    required this.absorberContext
  });

  @override
  Widget build(BuildContext context) {
    return _SearchedMangasWidgetStateful(
      searchedText: searchedText,
      absorberContext: absorberContext
    );
  }
}

class _SearchedMangasWidgetStateful extends StatefulWidget {
  final String searchedText;
  final BuildContext absorberContext;
  
  const _SearchedMangasWidgetStateful({
    required this.searchedText,
    required this.absorberContext
  });

  @override
  State<_SearchedMangasWidgetStateful> createState() => _SearchedMangasWidgetStatefulState();
}

class _SearchedMangasWidgetStatefulState extends State<_SearchedMangasWidgetStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late SearchedMangaController controller;

  @override void initState() {
    super.initState();
    controller = SearchedMangaController(context, widget.searchedText);
    controller.initializeController();
  }

  @override void dispose() {
    super.dispose();
    controller.dispose();
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
            if(isLoadingValue == true) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: skeletonLoadingDefaultLimit, 
                  (c, i) {
                    return shimmerSkeletonWidget(
                      CustomUserListMangaDisplay(
                        mangaData: MangaDataClass.fetchNewInstance(-1),
                        displayType: MangaRowDisplayType.search,
                        skeletonMode: true,
                        key: UniqueKey()
                      )
                    );
                  }
                )
              );
            }

            return ValueListenableBuilder(
              valueListenable: controller.mangasList,
              builder: (context, mangasList, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: mangasList.length, 
                    (c, i) {
                      if(appStateRepo.globalMangaData[mangasList[i]] != null){
                        return ValueListenableBuilder(
                          valueListenable: appStateRepo.globalMangaData[mangasList[i]]!.notifier, 
                          builder: (context, mangaData, child){
                            return CustomUserListMangaDisplay(
                              mangaData: mangaData,
                              displayType: MangaRowDisplayType.search,
                              skeletonMode: false,
                              key: UniqueKey()
                            );
                          }
                        );
                      }
                      return Text('${mangasList[i]}');
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