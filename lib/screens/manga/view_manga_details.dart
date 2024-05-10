import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMangaDetails extends ConsumerWidget {
  final int mangaID;

  const ViewMangaDetails({
    super.key,
    required this.mangaID
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ViewMangaDetailsStateful(
      mangaID: mangaID
    );
  }
}

class _ViewMangaDetailsStateful extends ConsumerStatefulWidget {
  final int mangaID;

  const _ViewMangaDetailsStateful({
    required this.mangaID
  });

  @override
  ConsumerState<_ViewMangaDetailsStateful> createState() => _ViewMangaDetailsStatefulState();
}

class _ViewMangaDetailsStatefulState extends ConsumerState<_ViewMangaDetailsStateful>{
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
        leading: const AppBarWidget(),
        title: const Text('Manga Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: Builder(
        builder: (context) {  
          AsyncValue<MangaDataClass> viewMangaDataState = ref.watch(controller.mangaDataNotifier);
          return RefreshIndicator(
            onRefresh: () => context.read(controller.mangaDataNotifier.notifier).refresh(),
            child: viewMangaDataState.when(
              data: (data) => CustomMangaDetails(
                mangaData: data,
                skeletonMode: false,
              ),
              error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()),
              loading: () => ShimmerWidget(
                child: CustomMangaDetails(
                  mangaData: MangaDataClass.fetchNewInstance(-1),
                  skeletonMode: true,
                  key: UniqueKey()
                )
              )
            ),
          );
        }
      )
    );
  }
}