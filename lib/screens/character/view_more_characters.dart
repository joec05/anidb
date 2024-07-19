import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMoreCharacters extends ConsumerWidget {
  final String label;
  final CharacterBasicDisplayType displayType;

  const ViewMoreCharacters({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ViewMoreCharactersStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMoreCharactersStateful extends ConsumerStatefulWidget {
  final String label;
  final CharacterBasicDisplayType displayType;

  const _ViewMoreCharactersStateful({
    required this.label,
    required this.displayType
  });

  @override
  ConsumerState<_ViewMoreCharactersStateful> createState() => _ViewMoreCharactersStatefulState();
}

class _ViewMoreCharactersStatefulState extends ConsumerState<_ViewMoreCharactersStateful>{
  late ViewMoreCharactersController controller;

  @override void initState(){
    super.initState();
    controller = ViewMoreCharactersController(widget.displayType);
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
          AsyncValue<List<CharacterDataClass>> viewCharacterDataState = ref.watch(controller.characterDataNotifier);
          return RefreshIndicator(
            onRefresh: () => context.read(controller.characterDataNotifier.notifier).refresh(),
            child: viewCharacterDataState.when(
              data: (data) => ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index){
                  return CustomCompleteCharacterDisplay(
                    characterData: data[index], 
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
                    child: CustomCompleteCharacterDisplay(
                      characterData: CharacterDataClass.fetchNewInstance(-1), 
                      skeletonMode: true,
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