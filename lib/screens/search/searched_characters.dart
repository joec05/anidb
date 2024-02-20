import 'package:anime_list_app/global_files.dart'; 
import 'package:flutter/material.dart';

class SearchedCharactersWidget extends StatelessWidget {
  final String searchedText;
  final BuildContext absorberContext;

  const SearchedCharactersWidget({
    super.key,
    required this.searchedText,
    required this.absorberContext
  });

  @override
  Widget build(BuildContext context) {
    return _SearchedCharactersWidgetStateful(
      searchedText: searchedText,
      absorberContext: absorberContext
    );
  }
}

class _SearchedCharactersWidgetStateful extends StatefulWidget {
  final String searchedText;
  final BuildContext absorberContext;
  
  const _SearchedCharactersWidgetStateful({
    required this.searchedText,
    required this.absorberContext
  });

  @override
  State<_SearchedCharactersWidgetStateful> createState() => _SearchedCharactersWidgetStatefulState();
}


class _SearchedCharactersWidgetStatefulState extends State<_SearchedCharactersWidgetStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late SearchedCharactersController controller;

  @override void initState() {
    super.initState();
    controller = SearchedCharactersController(context, widget.searchedText);
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
                      CustomRowCharacterDisplay(
                        characterData: CharacterDataClass.fetchNewInstance(-1),
                        skeletonMode: true,
                        key: UniqueKey()
                      )
                    );
                  }
                )
              );
            }

            return ValueListenableBuilder(
              valueListenable: controller.charactersList,
              builder: (context, charactersList, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: charactersList.length, 
                    (c, i) {
                      if(appStateRepo.globalCharacterData[charactersList[i]] != null){
                        return ValueListenableBuilder(
                          valueListenable: appStateRepo.globalCharacterData[charactersList[i]]!.notifier, 
                          builder: (context, characterData, child){
                            return CustomRowCharacterDisplay(
                              characterData: characterData,
                              skeletonMode: false,
                              key: UniqueKey()
                            );
                          }
                        );
                      }
                      return Container();
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