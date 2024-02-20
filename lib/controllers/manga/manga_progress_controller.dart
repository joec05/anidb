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

  void editMyMangaList(String status, int score, String volumeStr, String chapterStr) async{
    volumeStr = volumeStr.isEmpty ? '0' : volumeStr;
    chapterStr = chapterStr.isEmpty ? '0' : chapterStr;
    if(int.tryParse(volumeStr) == null || int.tryParse(chapterStr) == null){
      handler.displaySnackbar(
        context, 
        SnackbarType.error, 
        tErr.invalidInput
      );
    }else if((int.parse(volumeStr) > mangaData.totalVolumes && mangaData.totalVolumes > 0) || (int.parse(chapterStr) > mangaData.totalChapters && mangaData.totalChapters > 0)){
      handler.displaySnackbar(
        context, 
        SnackbarType.error, 
        tErr.maxValueReached
      );
    }else{
      if(status.isEmpty){
        status = 'reading';
      }
      var map = {
        'status': status,
        'score': score.toString(),
        'num_volumes_read': volumeStr,
        'num_chapters_read': chapterStr
      };
      var res = await apiCallRepo.runAPICall(
        context,
        APICallType.patch,
        malApiUrl,
        '$malApiUrl/manga/${mangaData.id}/my_list_status',
        map
      );
      if(res != null) {
        MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
        newMangaData.myListStatus = MangaMyListStatusClass.generateNewCopy(newMangaData.myListStatus);
        newMangaData.myListStatus!.volumesRead = int.parse(volumeStr);
        newMangaData.myListStatus!.chaptersRead = int.parse(chapterStr);
        newMangaData.myListStatus!.score = score;
        newMangaData.myListStatus!.updatedTime = DateTime.now().toIso8601String();
        newMangaData.myListStatus!.status = status;
        appStateRepo.globalMangaData[mangaData.id]!.notifier.value = newMangaData;
        UpdateUserMangaListStreamClass().emitData(
          UserMangaListStreamControllerClass(
            newMangaData
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

  void deleteFromMyMangaList() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.delete,
      malApiUrl,
      '$malApiUrl/manga/${mangaData.id}/my_list_status',
      {}
    );
    if(res != null) {
      MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
      newMangaData.myListStatus = null;
      appStateRepo.globalMangaData[mangaData.id]!.notifier.value = newMangaData;
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
    TextEditingController volumeController = TextEditingController();
    TextEditingController chapterController = TextEditingController();
    if(mangaData.myListStatus != null){
      selectedStatus = mangaData.myListStatus!.status ?? '';
      selectedScore = mangaData.myListStatus!.score;
      volumeController.text = mangaData.myListStatus!.volumesRead.toString();
      chapterController.text = mangaData.myListStatus!.chaptersRead.toString();
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
                                      mangaData.title, 
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
                        Text('Read status', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.95
                        )),
                        SizedBox(height: getScreenHeight() * 0.015),
                        SizedBox(
                          height: getScreenHeight() * 0.065,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mangaStatusMap.keys.toList().length,
                            itemBuilder: (c, i){
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: (){
                                  if(mounted){
                                    setState((){
                                      selectedStatus = mangaStatusMap.keys.toList()[i];
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
                                      color: selectedStatus == mangaStatusMap.keys.toList()[i] ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.5)
                                    )
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(mangaStatusMap[mangaStatusMap.keys.toList()[i]])
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
                        Text('Volumes read', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.95
                        )),
                        SizedBox(height: getScreenHeight() * 0.015),
                        TextField(
                          controller: volumeController,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          maxLength: 4,
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(horizontal: getScreenWidth() * 0.025),
                            fillColor: Colors.transparent,
                            filled: true,
                            hintText: 'Enter volumes read',
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
                              child: const Icon(
                                FontAwesomeIcons.plus
                              )
                            ),
                            suffixIcon: TextButton(
                              onPressed: (){
                                volumeController.text = '${max(0, int.tryParse(volumeController.text) != null ? int.parse(volumeController.text) - 1 : 0)}';
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
                        Text('Chapters read', style: TextStyle(
                          fontSize: defaultTextFontSize * 0.95
                        )),
                        SizedBox(height: getScreenHeight() * 0.015),
                        TextField(
                          controller: chapterController,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          maxLength: 4,
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(horizontal: getScreenWidth() * 0.025),
                            fillColor: Colors.transparent,
                            filled: true,
                            hintText: 'Enter chapters read',
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
                              child: const Icon(
                                FontAwesomeIcons.plus
                              )
                            ),
                            suffixIcon: TextButton(
                              onPressed: (){
                                chapterController.text = '${int.tryParse(chapterController.text) != null ? int.parse(chapterController.text) - 1 : 0}';
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
                            editMyMangaList(selectedStatus, selectedScore, volumeController.text, chapterController.text);
                          }, 
                          setBorderRadius: true
                        ),
                        SizedBox(height: getScreenHeight() * 0.02),
                        mangaData.myListStatus != null ?
                          Column(
                            children: [
                              CustomButton(
                                width: getScreenWidth() * 0.5, 
                                height: getScreenHeight() * 0.06,  
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