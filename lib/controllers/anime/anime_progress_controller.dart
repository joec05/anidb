import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnimeProgressController {
  final BuildContext context;
  final AnimeDataClass animeData;

  AnimeProgressController(
    this.context,
    this.animeData
  );

  bool get mounted => context.mounted;

  void editMyAnimeList(
    String status, 
    int score, 
    String episodeStr
  ) async{
    episodeStr = episodeStr.isEmpty ? '0' : episodeStr;
    if(int.tryParse(episodeStr) == null){
      handler.displaySnackbar(
        context, 
        SnackbarType.error, 
        tErr.invalidInput
      );
    }else if(int.parse(episodeStr) > animeData.totalEpisodes && animeData.totalEpisodes > 0){
      handler.displaySnackbar(
        context, 
        SnackbarType.error, 
        tErr.maxValueReached
      );
    }else{
      if(status.isEmpty){
        status = 'watching';
      }
      var map = {
        'status': status,
        'score': score.toString(),
        'num_watched_episodes': episodeStr
      };
      var res = await apiCallRepo.runAPICall(
        context,
        APICallType.patch,
        malApiUrl,
        '$malApiUrl/anime/${animeData.id}/my_list_status',
        map
      );
      if(res != null) {
        AnimeDataClass newAnimeData = AnimeDataClass.generateNewCopy(animeData);
        newAnimeData.myListStatus = AnimeMyListStatusClass.generateNewCopy(newAnimeData.myListStatus);
        newAnimeData.myListStatus!.episodesWatched = int.parse(episodeStr);
        newAnimeData.myListStatus!.score = score;
        newAnimeData.myListStatus!.updatedTime = DateTime.now().toIso8601String();
        newAnimeData.myListStatus!.status = status;
        appStateRepo.globalAnimeData[animeData.id]!.notifier.value = newAnimeData;
        UpdateUserAnimeListStreamClass().emitData(
          UserAnimeListStreamControllerClass(
            newAnimeData
          )
        );
        if(mounted){
          handler.displaySnackbar(
            context,
            SnackbarType.successful, 
            tSuccess.savedProgress
          );
        }
      }
    }
  }

  void deleteFromMyAnimeList() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.delete,
      malApiUrl,
      '$malApiUrl/anime/${animeData.id}/my_list_status',
      {}
    );
    if(res != null) {
      AnimeDataClass newAnimeData = AnimeDataClass.generateNewCopy(animeData);
      newAnimeData.myListStatus = null;
      appStateRepo.globalAnimeData[animeData.id]!.notifier.value = newAnimeData;
      if(mounted){
        handler.displaySnackbar(
          context,
          SnackbarType.successful, 
          tSuccess.deleteFromList
        );
      }
    }
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
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getScreenWidth() * 0.015,
                                    ),
                                    child: Text(
                                      animeData.title, 
                                      style: TextStyle(
                                        fontSize: defaultTextFontSize * 0.95,
                                        fontWeight: FontWeight.w600
                                      ),
                                      textAlign: TextAlign.center
                                    ),
                                  )
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
}