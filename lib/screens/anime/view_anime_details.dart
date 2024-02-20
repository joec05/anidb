import 'package:anime_list_app/global_files.dart';
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
  late AnimeDetailsController controller;

  @override void initState(){
    super.initState();
    controller = AnimeDetailsController(context, widget.animeID);
    controller.initializeController();
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
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
      body: ValueListenableBuilder(
        valueListenable: controller.isLoading,
        builder: (context, isLoadingValue, child) {
          if(isLoadingValue || appStateRepo.globalAnimeData[widget.animeID] == null){
            return shimmerSkeletonWidget(
              CustomAnimeDetails(
                animeData: AnimeDataClass.fetchNewInstance(-1),
                skeletonMode: true,
                key: UniqueKey()
              )
            );
          }
      
          return ValueListenableBuilder(
            valueListenable: appStateRepo.globalAnimeData[widget.animeID]!.notifier, 
            builder: (context, animeData, child){
              return CustomAnimeDetails(
                animeData: animeData,
                skeletonMode: false,
                key: UniqueKey()
              );
            }
          );
        }
      )
    );
  }

}