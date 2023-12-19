// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:anime_list_app/appdata/AppStateActions.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/class/MangaDataClass.dart';
import 'package:anime_list_app/custom/CustomUserListMangaDisplay.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchedMangasWidget extends StatelessWidget {
  String searchedText;
  BuildContext absorberContext;

  SearchedMangasWidget({
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
  String searchedText;
  BuildContext absorberContext;
  
  _SearchedMangasWidgetStateful({
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