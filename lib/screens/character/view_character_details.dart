import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewCharacterDetails extends ConsumerWidget {
  final int characterID;

  const ViewCharacterDetails({
    super.key,
    required this.characterID
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ViewCharacterDetailsStateful(
      characterID: characterID
    );
  }
}

class _ViewCharacterDetailsStateful extends ConsumerStatefulWidget {
  final int characterID;

  const _ViewCharacterDetailsStateful({
    required this.characterID
  });

  @override
  ConsumerState<_ViewCharacterDetailsStateful> createState() => _ViewCharacterDetailsStatefulState();
}

class _ViewCharacterDetailsStatefulState extends ConsumerState<_ViewCharacterDetailsStateful>{
  late CharacterDetailsController controller;

  @override void initState(){
    super.initState();
    controller = CharacterDetailsController(widget.characterID);
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
        title: const Text('Character Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: Builder(
        builder: (context) {  
          AsyncValue<CharacterDataClass> viewAnimeDataState = ref.watch(controller.characterDataNotifier);
          return RefreshIndicator(
            onRefresh: () => context.read(controller.characterDataNotifier.notifier).refresh(),
            child: viewAnimeDataState.when(
              data: (data) => CustomCharacterDetails(
                characterData: data,
                skeletonMode: false,
              ),
              error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()), 
              loading: () => ShimmerWidget(
                child: CustomCharacterDetails(
                  characterData: CharacterDataClass.fetchNewInstance(-1),
                  skeletonMode: true,
                )
              ),
            ),
          );
        }
      )
    );
  }

}