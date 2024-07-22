import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreAnime extends ConsumerWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const ViewMoreAnime({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ViewMoreAnimeStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMoreAnimeStateful extends ConsumerStatefulWidget {
  final String label;
  final AnimeBasicDisplayType displayType;

  const _ViewMoreAnimeStateful({
    required this.label,
    required this.displayType
  });

  @override
  ConsumerState<_ViewMoreAnimeStateful> createState() => _ViewMoreAnimeStatefulState();
}

class _ViewMoreAnimeStatefulState extends ConsumerState<_ViewMoreAnimeStateful>{
  late ViewMoreAnimeController controller;

  @override void initState(){
    super.initState();
    controller = ViewMoreAnimeController(widget.displayType);
    controller.initialize();
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarWidget(),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: Text(widget.label), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: Builder(
        builder: (context) {
          AsyncValue<List<AnimeDataClass>> viewAnimeDataState = ref.watch(controller.animeDataNotifier);
          return RefreshIndicator(
            onRefresh: () => context.read(controller.animeDataNotifier.notifier).refresh(),
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
                },
              ),
              error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()), 
              loading: () => ListView.builder(
                itemCount: getAnimeBasicDisplayTotalFetchCount(),
                itemBuilder: (context, index){
                  return ShimmerWidget(
                    child: CustomUserListAnimeDisplay(
                      animeData: AnimeDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
                      displayType: AnimeRowDisplayType.viewMore,
                      key: UniqueKey()
                    )
                  );
                }
              )
            ),
          );
        }
      )
    );
  }
}