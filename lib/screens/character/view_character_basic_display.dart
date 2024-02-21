import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ViewCharacterBasicDisplay extends StatelessWidget {
  final String label;
  final CharacterBasicDisplayType displayType;

  const ViewCharacterBasicDisplay({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewCharacterBasicDisplayStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewCharacterBasicDisplayStateful extends StatefulWidget {
  final String label;
  final CharacterBasicDisplayType displayType;

  const _ViewCharacterBasicDisplayStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewCharacterBasicDisplayStateful> createState() => _ViewCharacterBasicDisplayStatefulState();
}

class _ViewCharacterBasicDisplayStatefulState extends State<_ViewCharacterBasicDisplayStateful>{
  late CharacterBasicController controller;

  @override void initState(){
    super.initState();
    controller = CharacterBasicController(context, widget.displayType);
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
        leading: defaultLeadingWidget(context),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: Text(widget.label), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          controller.isLoading,
          controller.charactersList
        ]),
        builder: (context, child) {
          bool isLoading = controller.isLoading.value;
          List<int> charactersList = controller.charactersList.value;

          if(isLoading) {
            return GridView.builder(
              itemCount: getAnimeBasicDisplayTotalFetchCount(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
                childAspectRatio: gridChildRatio
              ),
              itemBuilder: (context, index){
                return shimmerSkeletonWidget(
                  CustomBasicCharacterDisplay(
                    showStats: false,
                    characterData: CharacterDataClass.fetchNewInstance(-1), 
                    skeletonMode: true,
                    key: UniqueKey()
                  )
                );
              }
            );
          }

          return GridView.builder(
            itemCount: charactersList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
              childAspectRatio: gridChildRatio
            ),
            itemBuilder: (context, index){
              return ValueListenableBuilder(
                valueListenable: appStateRepo.globalCharacterData[charactersList[index]]!.notifier, 
                builder: (context, characterData, child){
                  return CustomBasicCharacterDisplay(
                    showStats: true,
                    characterData: characterData, 
                    skeletonMode: false,
                    key: UniqueKey()
                  );
                }
              );
            },
          );
        }
      )
    );
  }
}