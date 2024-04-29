import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ViewMoreManga extends StatelessWidget {
  final String label;
  final MangaBasicDisplayType displayType;

  const ViewMoreManga({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewMoreMangaStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMoreMangaStateful extends StatefulWidget {
  final String label;
  final MangaBasicDisplayType displayType;

  const _ViewMoreMangaStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewMoreMangaStateful> createState() => _ViewMoreMangaStatefulState();
}

class _ViewMoreMangaStatefulState extends State<_ViewMoreMangaStateful>{
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
            return ListView.builder(
              itemCount: getAnimeBasicDisplayTotalFetchCount(),
              itemBuilder: (context, index){
                return shimmerSkeletonWidget(
                  CustomUserListMangaDisplay(
                    mangaData: MangaDataClass.fetchNewInstance(-1),
                    displayType: MangaRowDisplayType.viewMore, 
                    skeletonMode: true,
                    key: UniqueKey()
                  )
                );
              },
            );
          }
          
          return ListView.builder(
            itemCount: mangasList.length,
            itemBuilder: (context, index){
              return ValueListenableBuilder(
                valueListenable: appStateRepo.globalMangaData[mangasList[index]]!.notifier, 
                builder: (context, mangaData, child){
                  return CustomUserListMangaDisplay(
                    mangaData: mangaData,
                    displayType: MangaRowDisplayType.viewMore, 
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