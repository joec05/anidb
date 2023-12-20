import 'package:anime_list_app/appdata/app_state_actions.dart';
import 'package:anime_list_app/appdata/global_library.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/custom/custom_complete_manga_display.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:dio/dio.dart';
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
  List<int> mangasList = [];
  bool isLoading = false;

  @override void initState(){
    super.initState();
    if(mounted){
      fetchUserMangasList();
    }
  }
  
  void fetchUserMangasList() async{
    if(widget.searchedText.isNotEmpty){
      isLoading = true;
      var res = await dio.get(
        '$malApiUrl/manga?$fetchAllMangaFieldsStr&q=${widget.searchedText}&limit=$searchFetchLimit',
        options: Options(
          headers: {
            'Authorization': await generateAuthHeader()
          },
        )
      );
      List data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        updateMangaData(data[i]['node']);
        int id = data[i]['node']['id'];
        if(appStateClass.globalMangaData[id] != null){
          mangasList.add(id);
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
                CustomUserListMangaDisplay(
                  mangaData: MangaDataClass.fetchNewInstance(-1),
                  displayType: MangaRowDisplayType.search,
                  skeletonMode: true,
                  key: UniqueKey()
                )
              );
            }
          ))
        :
          SliverList(delegate: SliverChildBuilderDelegate(
            childCount: mangasList.length, 
            (c, i) {
              if(appStateClass.globalMangaData[mangasList[i]] != null){
                return ValueListenableBuilder(
                  valueListenable: appStateClass.globalMangaData[mangasList[i]]!.notifier, 
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
          ))
      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}