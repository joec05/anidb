import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedMangasWidget extends ConsumerWidget {
  final String searchedText;
  final BuildContext absorberContext;

  const SearchedMangasWidget({
    super.key,
    required this.searchedText,
    required this.absorberContext
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SearchedMangasWidgetStateful(
      searchedText: searchedText,
      absorberContext: absorberContext
    );
  }
}

class _SearchedMangasWidgetStateful extends ConsumerStatefulWidget {
  final String searchedText;
  final BuildContext absorberContext;
  
  const _SearchedMangasWidgetStateful({
    required this.searchedText,
    required this.absorberContext
  });

  @override
  ConsumerState<_SearchedMangasWidgetStateful> createState() => _SearchedMangasWidgetStatefulState();
}

class _SearchedMangasWidgetStatefulState extends ConsumerState<_SearchedMangasWidgetStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late SearchedMangaController controller;

  @override void initState() {
    super.initState();
    controller = SearchedMangaController(context, widget.searchedText);
    controller.initializeController();
  }

  @override void dispose() {
    super.dispose();
    controller.dispose();
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
    
            AsyncValue<List<MangaDataClass>> viewMangaDataState = ref.watch(controller.searchedMangaNotifier);
            return viewMangaDataState.when(
              data: (data) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: data.length, 
                  (c, i) {
                    return CustomUserListMangaDisplay(
                      mangaData: data[i],
                      displayType: MangaRowDisplayType.search,
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
                      child: CustomUserListMangaDisplay(
                        mangaData: MangaDataClass.fetchNewInstance(-1),
                        displayType: MangaRowDisplayType.search,
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