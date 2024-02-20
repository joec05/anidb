import 'package:anime_list_app/global_files.dart';
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
  late MangaDetailsController controller;

  @override void initState(){
    super.initState();
    controller = MangaDetailsController(context, widget.mangaID);
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
        leading: defaultLeadingWidget(context),
        title: const Text('Manga Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: ValueListenableBuilder(
        valueListenable: controller.isLoading,
        builder: (context, isLoadingValue, child) {
          if(isLoadingValue || appStateRepo.globalMangaData[widget.mangaID] == null) {
            return shimmerSkeletonWidget(
              CustomMangaDetails(
                mangaData: MangaDataClass.fetchNewInstance(-1),
                skeletonMode: true,
                key: UniqueKey()
              )
            );
          }
          
          return ValueListenableBuilder(
            valueListenable: appStateRepo.globalMangaData[widget.mangaID]!.notifier, 
            builder: (context, mangaData, child){
              return CustomMangaDetails(
                mangaData: mangaData,
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