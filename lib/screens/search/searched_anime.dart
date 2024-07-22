import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedAnimesWidget extends ConsumerWidget {
  final String searchedText;
  final BuildContext absorberContext;

  const SearchedAnimesWidget({
    super.key,
    required this.searchedText,
    required this.absorberContext
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SearchedAnimesWidgetStateful(
      searchedText: searchedText,
      absorberContext: absorberContext
    );
  }
}

class _SearchedAnimesWidgetStateful extends ConsumerStatefulWidget {
  final String searchedText;
  final BuildContext absorberContext;
  
  const _SearchedAnimesWidgetStateful({
    required this.searchedText,
    required this.absorberContext
  });

  @override
  ConsumerState<_SearchedAnimesWidgetStateful> createState() => _SearchedAnimesWidgetStatefulState();
}

class _SearchedAnimesWidgetStatefulState extends ConsumerState<_SearchedAnimesWidgetStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late SearchedAnimeController controller;

  @override void initState(){
    super.initState();
    controller = SearchedAnimeController(widget.searchedText);
    controller.initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(widget.absorberContext)
        ),
        Builder(
          builder: (context) {
            if(controller.searchedText.isEmpty) {
              return const SliverToBoxAdapter();
            }
    
            AsyncValue<List<AnimeDataClass>> viewAnimeDataState = ref.watch(controller.searchedAnimeNotifier);
            return viewAnimeDataState.when(
              data: (data) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: data.length, 
                  (c, i) {
                    return CustomUserListAnimeDisplay(
                      animeData: data[i],
                      displayType: AnimeRowDisplayType.search,
                      skeletonMode: false,
                      key: UniqueKey()
                    );
                  }
                )
              ),
              error: (obj, stackTrace) => SliverFillRemaining(
                hasScrollBody: false, 
                child: DisplayErrorWidget(displayText: obj.toString())
              ),
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: skeletonLoadingDefaultLimit, 
                  (c, i) {
                    return ShimmerWidget(
                      child: CustomUserListAnimeDisplay(
                        animeData: AnimeDataClass.fetchNewInstance(-1),
                        displayType: AnimeRowDisplayType.search,
                        skeletonMode: true,
                        key: UniqueKey()
                      )
                    );
                  }
                )
              )
            );
          }
        )
      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}