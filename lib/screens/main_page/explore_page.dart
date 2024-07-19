import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ExplorePageStateful();
  }
}

class _ExplorePageStateful extends ConsumerStatefulWidget {
  const _ExplorePageStateful();

  @override
  ConsumerState<_ExplorePageStateful> createState() => _ExplorePageStatefulState();
}

class _ExplorePageStatefulState extends ConsumerState<_ExplorePageStateful> with AutomaticKeepAliveClientMixin{
  late ExploreController controller;

  @override void initState(){
    super.initState();
    controller = ExploreController();
    controller.initialize();
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    AsyncValue<List<AnimeDataClass>> viewAnimeDataState = ref.watch(controller.exploreNotifier);

    return RefreshIndicator(
      onRefresh: () => context.read(controller.exploreNotifier.notifier).refresh(),
      child: viewAnimeDataState.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index){
            return CustomUserListAnimeDisplay(
              animeData: data[index], 
              displayType: AnimeRowDisplayType.viewMore,
              skeletonMode: false,
              key: UniqueKey()
            );
          }
        ),
        error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()),
        loading: () => ListView.builder(
          itemCount: getAnimeBasicDisplayTotalFetchCount(),
          itemBuilder: (context, index){
            return ShimmerWidget(
              child: CustomUserListAnimeDisplay(
                animeData: AnimeDataClass.fetchNewInstance(-1), 
                displayType: AnimeRowDisplayType.viewMore,
                skeletonMode: true,
                key: UniqueKey()
              )
            );
          }
        )
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}