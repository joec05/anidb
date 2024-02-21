import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ViewAnimeBasicDisplay extends StatelessWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const ViewAnimeBasicDisplay({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewAnimeBasicDisplayStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewAnimeBasicDisplayStateful extends StatefulWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const _ViewAnimeBasicDisplayStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewAnimeBasicDisplayStateful> createState() => _ViewAnimeBasicDisplayStatefulState();
}

class _ViewAnimeBasicDisplayStatefulState extends State<_ViewAnimeBasicDisplayStateful>{
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
            return GridView.builder(
              itemCount: getAnimeBasicDisplayTotalFetchCount(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
                childAspectRatio: gridChildRatio
              ),
              itemBuilder: (context, index){
                return shimmerSkeletonWidget(
                  CustomBasicAnimeDisplay(
                    animeData: AnimeDataClass.fetchNewInstance(-1), 
                    skeletonMode: true,
                    showStats: false,
                    key: UniqueKey()
                  )
                );
              }
            );
          }

          return GridView.builder(
            itemCount: animesList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
              childAspectRatio: gridChildRatio,
            ),
            itemBuilder: (context, index){
              return ValueListenableBuilder(
                valueListenable: appStateRepo.globalAnimeData[animesList[index]]!.notifier, 
                builder: (context, animeData, child){
                  return CustomBasicAnimeDisplay(
                    showStats: true,
                    animeData: animeData,
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