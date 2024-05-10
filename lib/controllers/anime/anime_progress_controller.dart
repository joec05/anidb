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

  AnimeMyListStatusClass? get myListStatus => appStateRepo.globalAnimeData[animeData.id] == null ? null : context.read(appStateRepo.globalAnimeData[animeData.id]!.notifier).getState();

  void editMyAnimeList(
    String status, 
    int score, 
    String episodeStr
  ) async{
    bool statusChanged = status != myListStatus?.status;
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
        status = 'plan_to_watch';
      } else if(status == 'completed') {
        episodeStr = max(animeData.totalEpisodes, int.parse(episodeStr)).toString();
      }
      var map = {
        'status': status,
        'score': score.toString(),
        'num_watched_episodes': episodeStr
      };
      APIResponseModel res = await apiCallRepo.runAPICall(
        context,
        APICallType.patch,
        malApiUrl,
        '$malApiUrl/anime/${animeData.id}/my_list_status',
        map
      );
      if(res.error == null && context.mounted) {
        AnimeMyListStatusClass updatedListStatus = AnimeMyListStatusClass.generateNewCopy(myListStatus);
        updatedListStatus.episodesWatched = int.parse(episodeStr);
        updatedListStatus.score = score;
        updatedListStatus.updatedTime = DateTime.now().toIso8601String();
        updatedListStatus.status = status;
        if(context.mounted) {
          updateAnimeStatusFromModel(context, animeData.id, updatedListStatus);
        }
        if(statusChanged) {
          UpdateUserAnimeListStreamClass().emitData(
            UserAnimeListStreamControllerClass(
              animeData
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
      } else {
        if(context.mounted) {
          handler.displaySnackbar(context, SnackbarType.error, tErr.response);
        }
      }
    }
  }

  void deleteFromMyAnimeList() async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      context,
      APICallType.delete,
      malApiUrl,
      '$malApiUrl/anime/${animeData.id}/my_list_status',
      {}
    );
    if(res.error == null) {
      if(context.mounted){
        context.read(appStateRepo.globalAnimeData[animeData.id]!.notifier).update(AnimeMyListStatusClass.generateNewInstance());
        UpdateUserAnimeListStreamClass().emitData(
          UserAnimeListStreamControllerClass(
            animeData
          )
        );
        handler.displaySnackbar(
          context,
          SnackbarType.successful, 
          tSuccess.deleteFromList
        );
      }
    } else {
      if(context.mounted) {
        handler.displaySnackbar(context, SnackbarType.error, tErr.response);
      }
    }
  }

  void openActionDrawer(){
    String selectedStatus = '';
    int selectedScore = 0;
    TextEditingController episodeController = TextEditingController();
    if(myListStatus != null){
      selectedStatus = myListStatus!.status ?? '';
      selectedScore = myListStatus!.score;
      episodeController.text = myListStatus!.episodesWatched.toString();
    }

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: themeModel.mode.value == ThemeMode.dark ? Theme.of(context).primaryColor : const Color.fromARGB(255, 194, 191, 191),
      context: context, 
      builder: (context){
        return StatefulBuilder(
          key: UniqueKey(),
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
                        myListStatus != null ?
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