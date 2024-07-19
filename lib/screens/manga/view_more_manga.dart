import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreManga extends ConsumerWidget {
  final String label;
  final MangaBasicDisplayType displayType;

  const ViewMoreManga({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ViewMoreMangaStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMoreMangaStateful extends ConsumerStatefulWidget {
  final String label;
  final MangaBasicDisplayType displayType;

  const _ViewMoreMangaStateful({
    required this.label,
    required this.displayType
  });

  @override
  ConsumerState<_ViewMoreMangaStateful> createState() => _ViewMoreMangaStatefulState();
}

class _ViewMoreMangaStatefulState extends ConsumerState<_ViewMoreMangaStateful>{
  late ViewMoreMangaController controller;

  @override void initState(){
    super.initState();
    controller = ViewMoreMangaController(widget.displayType);
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
          AsyncValue<List<MangaDataClass>> viewMangaDataState = ref.watch(controller.mangaDataNotifier);
          return RefreshIndicator(
            onRefresh: () => context.read(controller.mangaDataNotifier.notifier).refresh(),
            child: viewMangaDataState.when(
              data: (data) => ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index){
                  return CustomUserListMangaDisplay(
                    mangaData: data[index], 
                    displayType: MangaRowDisplayType.viewMore,
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
                    child: CustomUserListMangaDisplay(
                      mangaData: MangaDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
                      displayType: MangaRowDisplayType.viewMore,
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