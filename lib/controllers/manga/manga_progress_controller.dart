import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MangaProgressController {
  final BuildContext context;
  final MangaDataClass mangaData;

  MangaProgressController(
    this.context,
    this.mangaData
  );

  bool get mounted => context.mounted;

  MangaMyListStatusClass? get myListStatus => appStateRepo.globalMangaData[mangaData.id] == null ? null : context.read(appStateRepo.globalMangaData[mangaData.id]!.notifier).getState();

  void editMyMangaList(String status, int score, String volumeStr, String chapterStr) async{
    bool statusChanged = status != myListStatus?.status;
    volumeStr = volumeStr.isEmpty ? '0' : volumeStr;
    chapterStr = chapterStr.isEmpty ? '0' : chapterStr;
    if(int.tryParse(volumeStr) == null || int.tryParse(chapterStr) == null){
      handler.displaySnackbar(
        SnackbarType.error, 
        tErr.invalidInput
      );
    }else if((int.parse(volumeStr) > mangaData.totalVolumes && mangaData.totalVolumes > 0) || (int.parse(chapterStr) > mangaData.totalChapters && mangaData.totalChapters > 0)){
      handler.displaySnackbar(
        SnackbarType.error, 
        tErr.maxValueReached
      );
    }else{
      if(status.isEmpty){
        status = 'plan_to_read';
      } else if(status == 'completed') {
        volumeStr = max(mangaData.totalVolumes, int.parse(volumeStr)).toString();
        chapterStr = max(mangaData.totalChapters, int.parse(chapterStr)).toString();
      }

      var map = {
        'status': status,
        'score': score.toString(),
        'num_volumes_read': volumeStr,
        'num_chapters_read': chapterStr
      };
      APIResponseModel res = await apiCallRepo.runAPICall(
        APICallType.patch,
        malApiUrl,
        '$malApiUrl/manga/${mangaData.id}/my_list_status',
        map
      );
      if(res.error == null) {
        MangaMyListStatusClass updatedListStatus = MangaMyListStatusClass.generateNewCopy(myListStatus);
        updatedListStatus.volumesRead = int.parse(volumeStr);
        updatedListStatus.chaptersRead = int.parse(chapterStr);
        updatedListStatus.score = score;
        updatedListStatus.updatedTime = DateTime.now().toIso8601String();
        updatedListStatus.status = status;
        if(context.mounted) {
          updateMangaStatusFromModel(mangaData.id, updatedListStatus);
        }
        if(statusChanged) {
          UpdateUserMangaListStreamClass().emitData(
            UserMangaListStreamControllerClass(
              mangaData
            )
          );
        }
        if(context.mounted){
          handler.displaySnackbar(
            SnackbarType.successful, 
            tSuccess.savedProgress
          );
        }
      } else {
        if(context.mounted) {
          handler.displaySnackbar(SnackbarType.error, tErr.response);
        }
      }
    }
  }

  void deleteFromMyMangaList() async{
    APIResponseModel res = await apiCallRepo.runAPICall(
      APICallType.delete,
      malApiUrl,
      '$malApiUrl/manga/${mangaData.id}/my_list_status',
      {}
    );
    if(res.error == null && context.mounted) {
      context.read(appStateRepo.globalMangaData[mangaData.id]!.notifier).update(MangaMyListStatusClass.generateNewInstance());
      UpdateUserMangaListStreamClass().emitData(
        UserMangaListStreamControllerClass(
          mangaData
        )
      );
      if(mounted){
        handler.displaySnackbar(
          SnackbarType.successful, 
          tSuccess.deleteFromList
        );
      }
    } else {
      if(context.mounted) {
        handler.displaySnackbar(SnackbarType.error, tErr.response);
      }
    }
  }

  void openActionDrawer(){
    String selectedStatus = '';
    int selectedScore = 0;
    TextEditingController volumeController = TextEditingController();
    TextEditingController chapterController = TextEditingController();
    if(myListStatus != null){
      selectedStatus = myListStatus!.status ?? '';
      selectedScore = myListStatus!.score;
      volumeController.text = myListStatus!.volumesRead.toString();
      chapterController.text = myListStatus!.chaptersRead.toString();
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
                                      mangaData.title, 
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
                                Text('Read status', style: TextStyle(
                                  fontSize: defaultTextFontSize * 0.9,
                                  fontWeight: FontWeight.w500
                                )),
                                SizedBox(height: getScreenHeight() * 0.01),
                                DropdownButton(
                                  underline: Container(height: 1, color: themeModel.mode.value == ThemeMode.dark ? Colors.white : Colors.black,),
                                  value: selectedStatus.isEmpty ? null : selectedStatus,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'reading',
                                      child: Text('Reading')
                                    ),
                                    DropdownMenuItem(
                                      value: 'plan_to_read',
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
                        Text('Volumes read', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.9,
                          fontWeight: FontWeight.w500
                        )),
                        SizedBox(height: getScreenHeight() * 0.01),
                        SizedBox(
                          width: getScreenWidth() * 0.5,
                          child: TextField(
                            controller: volumeController,
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
                                      if(volumeController.text.isEmpty){
                                        volumeController.text = '0';
                                      }else if(mangaData.totalVolumes == 0){
                                        volumeController.text = '${int.parse(volumeController.text) + 1}';
                                      }else{
                                        volumeController.text = '${min(mangaData.totalVolumes, int.parse(volumeController.text) + 1)}';
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
                                  volumeController.text = '${max(0, int.tryParse(volumeController.text) != null ? int.parse(volumeController.text) - 1 : 0)}';
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
                        Text('Chapters read', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.9,
                          fontWeight: FontWeight.w500
                        )),
                        SizedBox(height: getScreenHeight() * 0.01),
                        SizedBox(
                          width: getScreenWidth() * 0.5,
                          child: TextField(
                            controller: chapterController,
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
                                      if(chapterController.text.isEmpty){
                                        chapterController.text = '0';
                                      }else if(mangaData.totalChapters == 0){
                                        chapterController.text = '${int.parse(chapterController.text) + 1}';
                                      }else{
                                        chapterController.text = '${min(mangaData.totalChapters, int.parse(chapterController.text) + 1)}';
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
                                  chapterController.text = '${int.tryParse(chapterController.text) != null ? int.parse(chapterController.text) - 1 : 0}';
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
                            editMyMangaList(selectedStatus, selectedScore, volumeController.text, chapterController.text);
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
                                  deleteFromMyMangaList();
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