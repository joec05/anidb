import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ViewMangaBasicDisplay extends StatelessWidget {
  final String label;
  final MangaBasicDisplayType displayType;

  const ViewMangaBasicDisplay({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewMangaBasicDisplayStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMangaBasicDisplayStateful extends StatefulWidget {
  final String label;
  final MangaBasicDisplayType displayType;

  const _ViewMangaBasicDisplayStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewMangaBasicDisplayStateful> createState() => _ViewMangaBasicDisplayStatefulState();
}

class _ViewMangaBasicDisplayStatefulState extends State<_ViewMangaBasicDisplayStateful>{
  late MangaBasicController controller;

  @override void initState(){
    super.initState();
    controller = MangaBasicController(context, widget.displayType);
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
          controller.mangasList
        ]),
        builder: (context, child) {
          bool isLoading = controller.isLoading.value;
          List<int> mangasList = controller.mangasList.value;

          if(isLoading) {
            return GridView.builder(
              itemCount: getAnimeBasicDisplayTotalFetchCount(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
                childAspectRatio: gridChildRatio
              ),
              itemBuilder: (context, index){
                return shimmerSkeletonWidget(
                  CustomBasicMangaDisplay(
                    mangaData: MangaDataClass.fetchNewInstance(-1), 
                    showStats: false,
                    skeletonMode: true,
                    key: UniqueKey()
                  )
                );
              },
            );
          }
          
          return GridView.builder(
            itemCount: mangasList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
              childAspectRatio: gridChildRatio
            ),
            itemBuilder: (context, index){
              return ValueListenableBuilder(
                valueListenable: appStateRepo.globalMangaData[mangasList[index]]!.notifier, 
                builder: (context, mangaData, child){
                  return CustomBasicMangaDisplay(
                    mangaData: mangaData, 
                    showStats: true,
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