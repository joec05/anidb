import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:anime_list_app/provider/theme_model.dart';
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
    bool statusChanged = status != animeData.myListStatus?.status;
    episodeStr = episodeStr.isEmpty ? '' : episodeStr;
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
        if(statusChanged) {
          UpdateUserAnimeListStreamClass().emitData(
            UserAnimeListStreamControllerClass(
              newAnimeData
            )
          );
        }
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
      backgroundColor: themeModel.mode.value == ThemeMode.dark ? Theme.of(context).primaryColor : const Color.fromARGB(255, 194, 191, 191),
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
                                      horizontal: getScreenWidth() * 0.03,
                                    ),
                                    child: Text(
                                      animeData.title, 
                                      style: TextStyle(
                                        fontSize: defaultTextFontSize,
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center
                                    ),
                                  )
                                )
                              ]
                            )
                          ]
                        ),
                        SizedBox(height: getScreenHeight() * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Watch status', style: TextStyle(
                                  fontSize: defaultTextFontSize * 0.9,
                                  fontWeight: FontWeight.w500
                                )),
                                SizedBox(height: getScreenHeight() * 0.01),
                                DropdownButton(
                                  underline: Container(height: 1, color: themeModel.mode.value == ThemeMode.dark ? Colors.white : Colors.black,),
                                  value: selectedStatus.isEmpty ? null : selectedStatus,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'watching',
                                      child: Text('Watching')
                                    ),
                                    DropdownMenuItem(
                                      value: 'plan_to_watch',
                                      child: Text('Planning')
                                    ),
                                    DropdownMenuItem(
                                      value: 'completed',
                                      child: Text('Completed')
                                    ),
                                    DropdownMenuItem(
                                      value: 'on_hold',
                                      child: Text('On hold')
                                    ),
                                    DropdownMenuItem(
                                      value: 'dropped',
                                      child: Text('Dropped')
                                    )
                                  ],
                                  onChanged: (dynamic item) {
                                    if(mounted){
                                      setState((){
                                        selectedStatus = item as String;
                                      });
                                    }
                                  }
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Score', style: TextStyle(
                                  fontSize: defaultTextFontSize * 0.9,
                                  fontWeight: FontWeight.w500
                                )),
                                SizedBox(height: getScreenHeight() * 0.01),
                                DropdownButton(
                                  underline: Container(height: 1, color: themeModel.mode.value == ThemeMode.dark ? Colors.white : Colors.black,),
                                  value: selectedScore == 0 ? null : selectedScore,
                                  items: List<DropdownMenuItem>.generate(10, (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text('${index + 1}')
                                  )),
                                  onChanged: (dynamic item) {
                                    if(mounted){
                                      setState((){
                                        selectedScore = item as int;
                                      });
                                    }
                                  }
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: getScreenHeight() * 0.03),
                        Text('Episodes watched', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.9,
                          fontWeight: FontWeight.w500
                        )),
                        SizedBox(height: getScreenHeight() * 0.01),
                        SizedBox(
                          width: getScreenWidth() * 0.5,
                          child: TextField(
                            controller: episodeController,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            maxLength: 4,
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.symmetric(horizontal: getScreenWidth() * 0.025),
                              fillColor: Colors.transparent,
                              filled: true,
                              hintText: '',
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
                                child: Icon(
                                  FontAwesomeIcons.plus,
                                  size: 17,
                                  color: themeModel.mode.value == ThemeMode.dark ? Colors.white : Colors.black
                                )
                              ),
                              suffixIcon: TextButton(
                                onPressed: (){
                                  episodeController.text = '${max(0, int.tryParse(episodeController.text) != null ? int.parse(episodeController.text) - 1 : 0)}';
                                },
                                child: Icon(
                                  FontAwesomeIcons.minus,
                                  size: 17,
                                  color: themeModel.mode.value == ThemeMode.dark ? Colors.white : Colors.black
                                )
                              ),
                              constraints: BoxConstraints(
                                maxWidth: getScreenWidth() * 0.75,
                                maxHeight: getScreenHeight() * 0.07,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(width: 2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(width: 2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(25),
                              ),
                            )
                          ),
                        ),
                        SizedBox(height: getScreenHeight() * 0.03),
                        CustomButton(
                          width: getScreenWidth() * 0.75, 
                          height: getScreenHeight() * 0.065,  
                          buttonColor: const Color.fromARGB(255, 8, 95, 86), 
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
                                width: getScreenWidth() * 0.75, 
                                height: getScreenHeight() * 0.065,
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