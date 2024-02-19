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
  List<int> charactersList = [];
  bool isLoading = false;

  @override void initState(){
    super.initState();
    if(mounted){
      fetchSearchedCharactersList();
    }
  }

  void fetchSearchedCharactersList() async{
    if(widget.searchedText.isNotEmpty){
      isLoading = true;
      String searchedText = widget.searchedText;
      var res = await dio.get(
        '$jikanApiUrl/characters?q=$searchedText'
      );
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        updateBasicCharacterData(data[i]);
        int id = data[i]['mal_id'];
        if(appStateClass.globalCharacterData[id] != null){
          charactersList.add(id);
        }
      }
      isLoading = false;
      if(mounted){
        setState((){}); 
      }
    }
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
        isLoading == true ?
          SliverList(delegate: SliverChildBuilderDelegate(
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
          ))
        :
          SliverList(delegate: SliverChildBuilderDelegate(
            childCount: charactersList.length, 
            (c, i) {
              if(appStateClass.globalCharacterData[charactersList[i]] != null){
                return ValueListenableBuilder(
                  valueListenable: appStateClass.globalCharacterData[charactersList[i]]!.notifier, 
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
          ))
      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}