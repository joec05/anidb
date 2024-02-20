import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExplorePageStateful();
  }
}

class _ExplorePageStateful extends StatefulWidget {
  const _ExplorePageStateful();

  @override
  State<_ExplorePageStateful> createState() => _ExplorePageStatefulState();
}

class _ExplorePageStatefulState extends State<_ExplorePageStateful> with AutomaticKeepAliveClientMixin{
  late ExploreController controller;

  @override void initState(){
    super.initState();
    controller = ExploreController(context);
    controller.initializeController();
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
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
              childAspectRatio: 0.675
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
            childAspectRatio: 0.675
          ),
          itemBuilder: (context, index){
            return ValueListenableBuilder(
              valueListenable: appStateRepo.globalAnimeData[animesList[index]]!.notifier, 
              builder: (context, animeData, child){
                return CustomBasicAnimeDisplay(
                  animeData: animeData, 
                  showStats: true,
                  skeletonMode: false,
                  key: UniqueKey()
                );
              }
            );
          }
        );
      }
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}