import 'package:anime_list_app/global_files.dart';
import 'package:anime_list_app/widgets/display/custom_complete_character_display.dart';
import 'package:flutter/material.dart';

class ViewMoreCharacters extends StatelessWidget {
  final String label;
  final CharacterBasicDisplayType displayType;

  const ViewMoreCharacters({
    super.key,
    required this.label,
    required this.displayType
  });

  @override
  Widget build(BuildContext context) {
    return _ViewMoreCharactersStateful(
      label: label,
      displayType: displayType
    );
  }
}

class _ViewMoreCharactersStateful extends StatefulWidget {
  final String label;
  final CharacterBasicDisplayType displayType;

  const _ViewMoreCharactersStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewMoreCharactersStateful> createState() => _ViewMoreCharactersStatefulState();
}

class _ViewMoreCharactersStatefulState extends State<_ViewMoreCharactersStateful>{
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
            return ListView.builder(
              itemCount: getAnimeBasicDisplayTotalFetchCount(),
              itemBuilder: (context, index){
                return shimmerSkeletonWidget(
                  CustomCompleteCharacterDisplay(
                    characterData: CharacterDataClass.fetchNewInstance(-1), 
                    skeletonMode: true,
                    key: UniqueKey()
                  )
                );
              }
            );
          }

          return ListView.builder(
            itemCount: charactersList.length,
            itemBuilder: (context, index){
              return ValueListenableBuilder(
                valueListenable: appStateRepo.globalCharacterData[charactersList[index]]!.notifier, 
                builder: (context, characterData, child){
                  return CustomCompleteCharacterDisplay(
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