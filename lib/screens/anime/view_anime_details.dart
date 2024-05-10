import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewAnimeDetails extends ConsumerWidget {
  final int animeID;

  const ViewAnimeDetails({
    super.key,
    required this.animeID
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ViewAnimeDetailsStateful(
      animeID: animeID
    );
  }
}

class _ViewAnimeDetailsStateful extends ConsumerStatefulWidget {
  final int animeID;

  const _ViewAnimeDetailsStateful({
    required this.animeID
  });

  @override
  ConsumerState<_ViewAnimeDetailsStateful> createState() => _ViewAnimeDetailsStatefulState();
}

class _ViewAnimeDetailsStatefulState extends ConsumerState<_ViewAnimeDetailsStateful>{
  late AnimeDetailsController controller;

  @override void initState(){
    super.initState();
    controller = AnimeDetailsController(context, widget.animeID);
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
        title: const Text('Anime Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: Builder(
        builder: (context) {  
          AsyncValue<AnimeDataClass> viewAnimeDataState = ref.watch(controller.animeDataNotifier);
          return RefreshIndicator(
            onRefresh: () => context.read(controller.animeDataNotifier.notifier).refresh(),
            child: viewAnimeDataState.when(
              data: (data) => CustomAnimeDetails(
                animeData: data,
                skeletonMode: false,
              ), 
              error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()), 
              loading: () => CustomAnimeDetails(
                animeData: AnimeDataClass.fetchNewInstance(-1),
                skeletonMode: true,
                key: UniqueKey()
              )
            ),
          );
        }
      )
    );
  }

}