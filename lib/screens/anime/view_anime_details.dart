import 'package:anime_list_app/global_files.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ViewAnimeDetails extends StatelessWidget {
  final int animeID;

  const ViewAnimeDetails({
    super.key,
    required this.animeID
  });

  @override
  Widget build(BuildContext context) {
    return _ViewAnimeDetailsStateful(
      animeID: animeID
    );
  }
}

class _ViewAnimeDetailsStateful extends StatefulWidget {
  final int animeID;

  const _ViewAnimeDetailsStateful({
    required this.animeID
  });

  @override
  State<_ViewAnimeDetailsStateful> createState() => _ViewAnimeDetailsStatefulState();
}

class _ViewAnimeDetailsStatefulState extends State<_ViewAnimeDetailsStateful>{
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchAnimeDetails();
    fetchAnimeCharacters();
  }

  @override void dispose(){
    super.dispose();
  }

  void fetchAnimeDetails() async{
    var res = await dio.get(
      '$malApiUrl/anime/${widget.animeID}?$fetchAllAnimeFieldsStr',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    updateAnimeData(res.data);
  }

  void fetchAnimeCharacters() async{
    var res = await dio.get(
      '$jikanApiUrl/anime/${widget.animeID}/characters'
    );
    var data = res.data['data'];
    AnimeDataClass animeData = appStateClass.globalAnimeData[widget.animeID]!.notifier.value;
    AnimeDataClass newAnimeData = AnimeDataClass.generateNewCopy(animeData);
    newAnimeData.characters = List.generate(data.length, (i){
      CharacterDataClass newCharacterData = CharacterDataClass.fetchNewInstance(data[i]['character']['mal_id']);
      newCharacterData.name = data[i]['character']['name'];
      newCharacterData.cover = CharacterImageClass(
        data[i]['character']['images']['jpg']['small_image_url'],
        data[i]['character']['images']['jpg']['image_url']
      );
      return newCharacterData;
    });
    appStateClass.globalAnimeData[widget.animeID]!.notifier.value = newAnimeData;
    isLoading = false;
    if(mounted){
      setState((){});
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Anime Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: !isLoading ? appStateClass.globalAnimeData[widget.animeID] != null ?
        ValueListenableBuilder(
          valueListenable: appStateClass.globalAnimeData[widget.animeID]!.notifier, 
          builder: (context, animeData, child){
            return CustomAnimeDetails(
              animeData: animeData,
              skeletonMode: false,
              key: UniqueKey()
            );
          }
        )
      : 
        shimmerSkeletonWidget(
          CustomAnimeDetails(
            animeData: AnimeDataClass.fetchNewInstance(-1),
            skeletonMode: true,
            key: UniqueKey()
          )
        )
      :
        shimmerSkeletonWidget(
          CustomAnimeDetails(
            animeData: AnimeDataClass.fetchNewInstance(-1),
            skeletonMode: true,
            key: UniqueKey()
          )
        )
    );
  }

}