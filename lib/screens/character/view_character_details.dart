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
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchCharacterDetails();
  }

  @override void dispose(){
    super.dispose();
  }

  void fetchCharacterDetails() async{
    var res = await dio.get(
      '$jikanApiUrl/characters/${widget.characterID}/full'
    );
    updateCharacterData(res.data['data']);
    isLoading = false;
    if(mounted){
      setState(() {});
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
        title: const Text('Character Details'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: !isLoading? appStateClass.globalCharacterData[widget.characterID] != null ?
        ValueListenableBuilder(
          valueListenable: appStateClass.globalCharacterData[widget.characterID]!.notifier, 
          builder: (context, characterData, child){
            return CustomCharacterDetails(
              characterData: characterData,
              skeletonMode: false,
              key: UniqueKey()
            );
          }
        )
      : 
        shimmerSkeletonWidget(
          CustomCharacterDetails(
            characterData: CharacterDataClass.fetchNewInstance(-1),
            skeletonMode: true,
            key: UniqueKey()
          )
        )
      : 
        shimmerSkeletonWidget(
          CustomCharacterDetails(
            characterData: CharacterDataClass.fetchNewInstance(-1),
            skeletonMode: true,
            key: UniqueKey()
          )
        )
    );
  }

}