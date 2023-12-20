import 'package:anime_list_app/appdata/app_state_actions.dart';
import 'package:anime_list_app/appdata/global_functions.dart';
import 'package:anime_list_app/appdata/global_variables.dart';
import 'package:anime_list_app/class/character_data_class.dart';
import 'package:anime_list_app/class/character_image_class.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/class/manga_statistics_class.dart';
import 'package:anime_list_app/custom/custom_manga_details.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ViewMangaDetails extends StatelessWidget {
  final int mangaID;

  const ViewMangaDetails({
    super.key,
    required this.mangaID
  });

  @override
  Widget build(BuildContext context) {
    return _ViewMangaDetailsStateful(
      mangaID: mangaID
    );
  }
}

class _ViewMangaDetailsStateful extends StatefulWidget {
  final int mangaID;

  const _ViewMangaDetailsStateful({
    required this.mangaID
  });

  @override
  State<_ViewMangaDetailsStateful> createState() => _ViewMangaDetailsStatefulState();
}

class _ViewMangaDetailsStatefulState extends State<_ViewMangaDetailsStateful>{
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchMangaDetails();
    fetchMangaStatistics();
    fetchMangaCharacters();
  }

  @override void dispose(){
    super.dispose();
  }

  void fetchMangaDetails() async{
    var res = await dio.get(
      '$malApiUrl/manga/${widget.mangaID}?$fetchAllMangaFieldsStr',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    updateMangaData(res.data);
  }

  void fetchMangaStatistics() async{
    var res = await dio.get(
      '$jikanApiUrl/manga/${widget.mangaID}/statistics'
    );
    var data = res.data['data'];
    MangaDataClass mangaData = appStateClass.globalMangaData[widget.mangaID]!.notifier.value;
    MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
    newMangaData.statistics = MangaStatisticsClass(
      data['reading'], 
      data['completed'], 
      data['on_hold'], 
      data['dropped'], 
      data['plan_to_read']
    );
    appStateClass.globalMangaData[widget.mangaID]!.notifier.value = newMangaData;
    isLoading = false;
    if(mounted){
      setState((){});
    }
  }
  
  void fetchMangaCharacters() async{
    var res = await dio.get(
      '$jikanApiUrl/manga/${widget.mangaID}/characters'
    );
    var data = res.data['data'];
    MangaDataClass mangaData = appStateClass.globalMangaData[widget.mangaID]!.notifier.value;
    MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
    newMangaData.characters = List.generate(data.length, (i){
      CharacterDataClass newCharacterData = CharacterDataClass.fetchNewInstance(data[i]['character']['mal_id']);
      newCharacterData.name = data[i]['character']['name'];
      newCharacterData.cover = CharacterImageClass(
        data[i]['character']['images']['jpg']['small_image_url'],
        data[i]['character']['images']['jpg']['image_url']
      );
      return newCharacterData;
    });
    appStateClass.globalMangaData[widget.mangaID]!.notifier.value = newMangaData;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        leading: defaultLeadingWidget(context),
        title: const Text('Manga Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: !isLoading ? appStateClass.globalMangaData[widget.mangaID] != null ?
        ValueListenableBuilder(
          valueListenable: appStateClass.globalMangaData[widget.mangaID]!.notifier, 
          builder: (context, mangaData, child){
            return CustomMangaDetails(
              mangaData: mangaData,
              skeletonMode: false,
              key: UniqueKey()
            );
          }
        )
      :
        shimmerSkeletonWidget(
          CustomMangaDetails(
            mangaData: MangaDataClass.fetchNewInstance(-1),
            skeletonMode: true,
            key: UniqueKey()
          )
        )
      :
        shimmerSkeletonWidget(
          CustomMangaDetails(
            mangaData: MangaDataClass.fetchNewInstance(-1),
            skeletonMode: true,
            key: UniqueKey()
          )
        )
    );
  }

}