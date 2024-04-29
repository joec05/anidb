import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ViewMoreAnime extends StatelessWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const ViewMoreAnime({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewMoreAnimeStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMoreAnimeStateful extends StatefulWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const _ViewMoreAnimeStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewMoreAnimeStateful> createState() => _ViewMoreAnimeStatefulState();
}

class _ViewMoreAnimeStatefulState extends State<_ViewMoreAnimeStateful>{
  late AnimeBasicController controller;

  @override void initState(){
    super.initState();
    controller = AnimeBasicController(context, widget.displayType);
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
        leading: defaultLeadingWidget(context),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: Text(widget.label), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          controller.isLoading,
          controller.animesList
        ]),
        builder: (context, child) {
          bool isLoading = controller.isLoading.value;
          List<int> animesList = controller.animesList.value;
          
          if(isLoading) {
            return ListView.builder(
              itemCount: getAnimeBasicDisplayTotalFetchCount(),
              itemBuilder: (context, index){
                return shimmerSkeletonWidget(
                  CustomUserListAnimeDisplay(
                    animeData: AnimeDataClass.fetchNewInstance(-1), 
                    skeletonMode: true,
                    displayType: AnimeRowDisplayType.viewMore,
                    key: UniqueKey()
                  )
                );
              }
            );
          }

          return ListView.builder(
            itemCount: animesList.length,
            itemBuilder: (context, index){
              return ValueListenableBuilder(
                valueListenable: appStateRepo.globalAnimeData[animesList[index]]!.notifier, 
                builder: (context, animeData, child){
                  return CustomUserListAnimeDisplay(
                    animeData: animeData, 
                    displayType: AnimeRowDisplayType.viewMore,
                    skeletonMode: false,
                    key: UniqueKey()
                  );
                }
              );
            },
          );
        }
      )
    );
  }
}