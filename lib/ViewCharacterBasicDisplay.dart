// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'dart:async';
import 'package:anime_list_app/appdata/AppStateActions.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/class/CharacterDataClass.dart';
import 'package:anime_list_app/custom/CustomBasicCharacterDisplay.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:flutter/material.dart';

class ViewCharacterBasicDisplay extends StatelessWidget {
  String label;
  CharacterBasicDisplayType displayType;

  ViewCharacterBasicDisplay({
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
  String label;
  CharacterBasicDisplayType displayType;

  _ViewCharacterBasicDisplayStateful({
    required this.label,
    required this.displayType
  });

  @override
  State<_ViewCharacterBasicDisplayStateful> createState() => _ViewCharacterBasicDisplayStatefulState();
}

class _ViewCharacterBasicDisplayStatefulState extends State<_ViewCharacterBasicDisplayStateful>{
  List<int> charactersList = [];
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchCharactersList();
  }

  @override void dispose(){
    super.dispose();
  }

  String generateAPIRequestPath(){
    CharacterBasicDisplayType type = widget.displayType;
    if(type == CharacterBasicDisplayType.top){
      return '$jikanApiUrl/top/characters?limit=24';
    }
    return '';
  }

  Future<void> fetchCharactersList() async{
    try {
      if(mounted){
        var res = await dio.get(
          generateAPIRequestPath()
        );
        var data = res.data['data'];
        for(int i = 0; i < data.length; i++){
          updateBasicCharacterData(data[i]);
          charactersList.add(data[i]['mal_id']);
        }
        isLoading = false;
        if(mounted){
          setState((){});
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
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
      body: !isLoading ?
        GridView.builder(
          itemCount: charactersList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
            childAspectRatio: 0.675
          ),
          itemBuilder: (context, index){
            return ValueListenableBuilder(
              valueListenable: appStateClass.globalCharacterData[charactersList[index]]!.notifier, 
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
        )
      :
        GridView.builder(
          itemCount: getAnimeBasicDisplayTotalFetchCount(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getAnimeBasicDisplayCrossAxis(),    
            childAspectRatio: 0.675
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
        )
    );
  }
}