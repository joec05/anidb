import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedCharactersWidget extends ConsumerWidget {
  final String searchedText;
  final BuildContext absorberContext;

  const SearchedCharactersWidget({
    super.key,
    required this.searchedText,
    required this.absorberContext
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SearchedCharactersWidgetStateful(
      searchedText: searchedText,
      absorberContext: absorberContext
    );
  }
}

class _SearchedCharactersWidgetStateful extends ConsumerStatefulWidget {
  final String searchedText;
  final BuildContext absorberContext;
  
  const _SearchedCharactersWidgetStateful({
    required this.searchedText,
    required this.absorberContext
  });

  @override
  ConsumerState<_SearchedCharactersWidgetStateful> createState() => _SearchedCharactersWidgetStatefulState();
}


class _SearchedCharactersWidgetStatefulState extends ConsumerState<_SearchedCharactersWidgetStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late SearchedCharactersController controller;

  @override void initState() {
    super.initState();
    controller = SearchedCharactersController(widget.searchedText);
    controller.initialize();
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
    
            AsyncValue<List<CharacterDataClass>> viewCharacterDataState = ref.watch(controller.searchedCharactersNotifier);
            return viewCharacterDataState.when(
              data: (data) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: data.length, 
                  (c, i) {
                    return CustomRowCharacterDisplay(
                      characterData: data[i],
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
                      child: CustomRowCharacterDisplay(
                        characterData: CharacterDataClass.fetchNewInstance(-1),
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