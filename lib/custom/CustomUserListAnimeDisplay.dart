// ignore_for_file: use_build_context_synchronously
import 'dart:math';
import 'package:anime_list_app/ViewAnimeDetails.dart';
import 'package:anime_list_app/appdata/GlobalEnums.dart';
import 'package:anime_list_app/appdata/GlobalFunctions.dart';
import 'package:anime_list_app/appdata/GlobalVariables.dart';
import 'package:anime_list_app/class/AnimeDataClass.dart';
import 'package:anime_list_app/class/AnimeMyListStatusClass.dart';
import 'package:anime_list_app/custom/CustomButton.dart';
import 'package:anime_list_app/extensions/StringEllipsis.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/streams/UpdateUserAnimeListStream.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:anime_list_app/transition/RightToLeftTransition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomUserListAnimeDisplay extends StatefulWidget {
  final AnimeDataClass animeData;
  final AnimeRowDisplayType displayType;
  final bool skeletonMode;

  const CustomUserListAnimeDisplay({
    super.key,
    required this.animeData,
    required this.displayType,
    required this.skeletonMode
  });

  @override
  State<CustomUserListAnimeDisplay> createState() => CustomUserListAnimeDisplayState();
}

class CustomUserListAnimeDisplayState extends State<CustomUserListAnimeDisplay>{
  late AnimeDataClass animeData;

  @override void initState(){
    super.initState();
    animeData = widget.animeData;
  }

  @override void dispose(){
    super.dispose();
  }

  void editMyAnimeList(String status, int score, String episodeStr) async{
    episodeStr = episodeStr.isEmpty ? '0' : episodeStr;
    if(int.tryParse(episodeStr) == null && widget.displayType == AnimeRowDisplayType.myUserList){
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Alert', textAlign: TextAlign.center),
            titlePadding: EdgeInsets.only(top: getScreenHeight() * 0.025),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Invalid input!!!', style: TextStyle(fontSize: defaultTextFontSize)),
                SizedBox(
                  height: getScreenHeight() * 0.02,
                ),
                CustomButton(
                  width: getScreenWidth() * 0.5, 
                  height: getScreenHeight() * 0.06, 
                  buttonColor: Colors.orange, 
                  buttonText: 'OK', 
                  onTapped: () => Navigator.of(dialogContext).pop(), 
                  setBorderRadius: true
                )
              ]
            )
          );
        }
      );
    }else if(int.parse(episodeStr) > animeData.totalEpisodes && animeData.totalEpisodes > 0){
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Alert', textAlign: TextAlign.center,),
            titlePadding: EdgeInsets.only(top: getScreenHeight() * 0.025),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Maximum value reached!!!', style: TextStyle(fontSize: defaultTextFontSize)),
                SizedBox(
                  height: getScreenHeight() * 0.02,
                ),
                CustomButton(
                  width: getScreenWidth() * 0.5, 
                  height: getScreenHeight() * 0.06, 
                  buttonColor: Colors.orange, 
                  buttonText: 'OK', 
                  onTapped: () => Navigator.of(dialogContext).pop(), 
                  setBorderRadius: true
                )
              ]
            )
          );
        }
      );
    }else{
      if(status.isEmpty){
        status = 'watching';
      }
      var map = {
        'status': status,
        'score': score.toString(),
        'num_watched_episodes': episodeStr,
      };
      var res = await dio.patch(
        '$malApiUrl/anime/${animeData.id}/my_list_status',
        data: map,
        options: Options(
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            'Authorization': await generateAuthHeader()
          },
        ),
      );
      if(res.statusCode == 200){
        AnimeDataClass newAnimeData = AnimeDataClass.generateNewCopy(animeData);
        newAnimeData.myListStatus = AnimeMyListStatusClass.generateNewCopy(newAnimeData.myListStatus);
        newAnimeData.myListStatus!.episodesWatched = int.parse(episodeStr);
        newAnimeData.myListStatus!.score = score;
        newAnimeData.myListStatus!.updatedTime = DateTime.now().toIso8601String();
        newAnimeData.myListStatus!.status = status;
        appStateClass.globalAnimeData[animeData.id]!.notifier.value = newAnimeData;
        UpdateUserAnimeListStreamClass().emitData(
          UserAnimeListStreamControllerClass(
            newAnimeData
          )
        );
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Successfully deleted from list')
          ));
        }
      }
    }
  }

  void deleteFromMyAnimeList() async{
    var res = await dio.delete(
      '$malApiUrl/anime/${animeData.id}/my_list_status',
      options: Options(
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': await generateAuthHeader()
        },
      ),
    );
    if(res.statusCode == 200){
      AnimeDataClass newAnimeData = AnimeDataClass.generateNewCopy(animeData);
      newAnimeData.myListStatus = null;
      appStateClass.globalAnimeData[animeData.id]!.notifier.value = newAnimeData;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted from list')
      ));
    }
  }

   Future<DateTime> initializeDatePicker(BuildContext context, DateTime selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100));
      if(picked != null && picked != selectedDate) {
        return picked;
      }
      return selectedDate;
  }

  void openActionDrawer(){
    String selectedStatus = '';
    int selectedScore = 0;
    TextEditingController episodeController = TextEditingController();
    if(animeData.myListStatus != null){
      selectedStatus = animeData.myListStatus!.status ?? '';
      selectedScore = animeData.myListStatus!.score;
      episodeController.text = animeData.myListStatus!.episodesWatched.toString();
    }
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context, 
      builder: (context){
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Wrap(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)
                      )
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: getScreenHeight() * 0.02),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(animeData.title, style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.9,
                                    fontWeight: FontWeight.w600
                                  ))
                                )
                              ]
                            )
                          ]
                        ),
                        SizedBox(height: getScreenHeight() * 0.03),
                        Text('Watch status', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.95
                        )),
                        SizedBox(height: getScreenHeight() * 0.015),
                        SizedBox(
                          height: getScreenHeight() * 0.065,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: animeStatusMap.keys.toList().length,
                            itemBuilder: (c, i){
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: (){
                                  if(mounted){
                                    setState((){
                                      selectedStatus = animeStatusMap.keys.toList()[i];
                                    });
                                  }
                                },
                                child: Container(
                                  width: getScreenWidth() * 0.25,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: getScreenWidth() * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(17.5),
                                    border: Border.all(
                                      width: 2,
                                      color: selectedStatus == animeStatusMap.keys.toList()[i] ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.5)
                                    )
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(animeStatusMap[animeStatusMap.keys.toList()[i]])
                                    ]
                                  )
                                )
                              );
                            }
                          ),
                        ),
                        SizedBox(height: getScreenHeight() * 0.03),
                        Text('Score', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.95
                        )),
                        SizedBox(height: getScreenHeight() * 0.015),
                        SizedBox(
                          height: getScreenHeight() * 0.065,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 10,
                            itemBuilder: (c, i){
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: (){
                                  if(mounted){
                                    setState((){
                                      selectedScore = i + 1;
                                    });
                                  }
                                },
                                child: Container(
                                  width: getScreenWidth() * 0.25,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: getScreenWidth() * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(17.5),
                                    border: Border.all(
                                      width: 2,
                                      color: selectedScore == i + 1 ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.5)
                                    )
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('${i + 1}')
                                    ]
                                  )
                                )
                              );
                            }
                          ),
                        ),
                        SizedBox(height: getScreenHeight() * 0.03),
                        Text('Episodes watched', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.95
                        )),
                        SizedBox(height: getScreenHeight() * 0.015),
                        TextField(
                          controller: episodeController,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          maxLength: 4,
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(horizontal: getScreenWidth() * 0.025),
                            fillColor: Colors.transparent,
                            filled: true,
                            hintText: 'Enter episodes watched',
                            prefixIcon: TextButton(
                              onPressed: (){
                                if(mounted){
                                  setState((){
                                    if(episodeController.text.isEmpty){
                                      episodeController.text = '0';
                                    }else if(animeData.totalEpisodes == 0){
                                      episodeController.text = '${int.parse(episodeController.text) + 1}';
                                    }else{
                                      episodeController.text = '${min(animeData.totalEpisodes, int.parse(episodeController.text) + 1)}';
                                    }
                                  });
                                }
                              },
                              child: const Icon(
                                FontAwesomeIcons.plus
                              )
                            ),
                            suffixIcon: TextButton(
                              onPressed: (){
                                episodeController.text = '${max(0, int.tryParse(episodeController.text) != null ? int.parse(episodeController.text) - 1 : 0)}';
                              },
                              child: const Icon(
                                FontAwesomeIcons.minus
                              )
                            ),
                            constraints: BoxConstraints(
                              maxWidth: getScreenWidth() * 0.75,
                              maxHeight: getScreenHeight() * 0.07,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.75), width: 2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.75), width: 2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          )
                        ),
                        SizedBox(height: getScreenHeight() * 0.03),
                        CustomButton(
                          width: getScreenWidth() * 0.5, 
                          height: getScreenHeight() * 0.06,  
                          buttonColor: Colors.brown, 
                          buttonText: 'Save', 
                          onTapped: (){
                            Navigator.pop(context);
                            editMyAnimeList(selectedStatus, selectedScore, episodeController.text);
                          }, 
                          setBorderRadius: true
                        ),
                        SizedBox(height: getScreenHeight() * 0.02),
                        animeData.myListStatus != null ?
                          Column(
                            children: [
                              CustomButton(
                                width: getScreenWidth() * 0.5, 
                                height: getScreenHeight() * 0.06,  
                                buttonColor: Colors.redAccent, 
                                buttonText: 'Delete from list', 
                                onTapped: (){
                                  Navigator.pop(context);
                                  deleteFromMyAnimeList();
                                }, 
                                setBorderRadius: true
                              ),
                              SizedBox(height: getScreenHeight() * 0.02)
                            ]
                          )
                        : Container()
                      ]
                    )
                  )
                ]
              )
            );
          }
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if(!widget.skeletonMode){
      if(animeData.myListStatus == null && widget.displayType == AnimeRowDisplayType.myUserList){
        return Container();
      }
      return GestureDetector(
        onTap: (){
          runDelay(() => Navigator.push(
            context,
            SliderRightToLeftRoute(
              page: ViewAnimeDetails(
                animeID: animeData.id
              )
            )
          ), navigatorDelayTime);
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding,
              vertical: defaultVerticalPadding
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: animeDisplayCoverSize.width,
                      height: animeDisplayCoverSize.height,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Colors.grey.withOpacity(0.6)
                        ),
                      ),
                      child: animeData.cover != null ? Image.network(animeData.cover!.large, fit: BoxFit.cover) : Image.asset("assets/images/anime-no-image.png", fit: BoxFit.cover)
                    ),
                    SizedBox(
                      width: getScreenWidth() * 0.025
                    ),
                    Flexible(
                      child: SizedBox(
                        width: getScreenWidth() - animeDisplayCoverSize.width - defaultHorizontalPadding * 2,
                        height: animeDisplayCoverSize.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        StringEllipsis.convertToEllipsis(animeData.title), 
                                        style: TextStyle(
                                          fontSize: defaultTextFontSize * 0.975,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis
                                      )
                                    )
                                  ]
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.005
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star, color: Colors.white, size: 20),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                          child: Text('${animeData.mean ?? '-'}', style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600
                                          ))
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: getScreenWidth() * 0.025
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.table_chart, color: Colors.white, size: 18),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                          child: Text('#${animeData.rank ?? '-'}', style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                          ))
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: getScreenWidth() * 0.025
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person_pin_rounded, color: Colors.white, size: 18.5),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(getScreenWidth() * 0.003, getScreenHeight() * 0.004, 0, 0),
                                          child: Text('#${animeData.popularity ?? '-'}', style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                          ))
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.005
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(getFormattedAnimeMediaType(animeData.mediaType), style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                    )),
                                    SizedBox(
                                      width: getScreenWidth() * 0.0075
                                    ),
                                    const Text('-'),
                                    SizedBox(
                                      width: getScreenWidth() * 0.0075
                                    ),
                                    animeData.startSeason != null ? animeData.startSeason!.year != null ?
                                      Row(
                                        children: [
                                          Text('${animeData.startSeason!.season[0].toUpperCase()}${animeData.startSeason!.season.substring(1)} ${animeData.startSeason!.year!}', style: TextStyle(
                                            fontSize: defaultTextFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                          )),
                                          SizedBox(
                                            width: getScreenWidth() * 0.0075
                                          ),
                                          const Text('-'),
                                          SizedBox(
                                            width: getScreenWidth() * 0.0075
                                          ),
                                        ]
                                      )
                                    : Container() : Container(),
                                    Text(getAnimeStatus(animeData.status), style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                    )),
                                  ],
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.01
                                ),
                                animeData.myListStatus != null ?
                                  CustomButton(
                                    width: getScreenWidth() - animeDisplayCoverSize.width - defaultHorizontalPadding * 2, 
                                    height: getScreenHeight() * 0.05, 
                                    buttonColor: Colors.brown.withOpacity(0.4), 
                                    buttonText: 'Edit in list', 
                                    onTapped: () => openActionDrawer(), 
                                    setBorderRadius: true
                                  )
                                : 
                                  CustomButton(
                                    width: getScreenWidth() - animeDisplayCoverSize.width - defaultHorizontalPadding * 2, 
                                    height: getScreenHeight() * 0.05, 
                                    buttonColor: Colors.brown.withOpacity(0.4), 
                                    buttonText: 'Add to list', 
                                    onTapped: () => openActionDrawer(), 
                                    setBorderRadius: true
                                  )
                              ]
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    StringEllipsis.convertToEllipsis(animeData.genres.map((e) => e.name).toList().join(', ')), 
                                    style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.85,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis
                                  )
                                )
                              ]
                            ),
                          ]
                        )
                      )
                    )
                  ],
                ),
              ]
            )
          ),
        )
      );
    }else{
      return Card(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: defaultHorizontalPadding,
              vertical: defaultVerticalPadding
            ),
            width: animeDisplayCoverSize.width,
            height: animeDisplayCoverSize.height,
          ),
        )
      ); 
    }
  }

}