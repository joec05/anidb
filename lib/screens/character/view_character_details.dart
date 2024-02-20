import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ViewCharacterDetails extends StatelessWidget {
  final int characterID;

  const ViewCharacterDetails({
    super.key,
    required this.characterID
  });

  @override
  Widget build(BuildContext context) {
    return _ViewCharacterDetailsStateful(
      characterID: characterID
    );
  }
}

class _ViewCharacterDetailsStateful extends StatefulWidget {
  final int characterID;

  const _ViewCharacterDetailsStateful({
    required this.characterID
  });

  @override
  State<_ViewCharacterDetailsStateful> createState() => _ViewCharacterDetailsStatefulState();
}

class _ViewCharacterDetailsStatefulState extends State<_ViewCharacterDetailsStateful>{
  late CharacterDetailsController controller;

  @override void initState(){
    super.initState();
    controller = CharacterDetailsController(context, widget.characterID);
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
        title: const Text('Character Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: ValueListenableBuilder(
        valueListenable: controller.isLoading,
        builder: (context, isLoadingValue, child) {
          if(isLoadingValue || appStateRepo.globalCharacterData[widget.characterID] == null) {
            return shimmerSkeletonWidget(
              CustomCharacterDetails(
                characterData: CharacterDataClass.fetchNewInstance(-1),
                skeletonMode: true,
                key: UniqueKey()
              )
            );
          }
          return ValueListenableBuilder(
            valueListenable: appStateRepo.globalCharacterData[widget.characterID]!.notifier, 
            builder: (context, characterData, child){
              return CustomCharacterDetails(
                characterData: characterData,
                skeletonMode: false,
                key: UniqueKey()
              );
            }
          );
        }
      )
    );
  }

}