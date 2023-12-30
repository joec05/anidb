import 'dart:math';
import 'package:anime_list_app/appdata/global_library.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/class/manga_my_list_status_class.dart';
import 'package:anime_list_app/class/manga_statistics_class.dart';
import 'package:anime_list_app/custom/custom_basic_character_display.dart';
import 'package:anime_list_app/custom/custom_basic_manga_display.dart';
import 'package:anime_list_app/custom/custom_button.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/streams/update_user_manga_list_stream.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class CustomMangaDetails extends StatefulWidget {
  final MangaDataClass mangaData;
  final bool skeletonMode;

  const CustomMangaDetails({
    super.key,
    required this.mangaData,
    required this.skeletonMode
  });

  @override
  State<CustomMangaDetails> createState() => CustomMangaDetailsState();
}

class CustomMangaDetailsState extends State<CustomMangaDetails>{
  late MangaDataClass mangaData;
  ValueNotifier<SelectedTitle> selectedTitle = ValueNotifier(SelectedTitle.main);
  List<MangaDataClass> relatedMangasData = [];

  @override void initState(){
    super.initState();
    mangaData = widget.mangaData;
    relatedMangasData = List.generate(mangaData.relatedMangas.length, (i){
      MangaDataClass newMangaData = MangaDataClass.fetchNewInstance(mangaData.relatedMangas[i].id);
      newMangaData.title = mangaData.relatedMangas[i].title;
      newMangaData.cover = mangaData.relatedMangas[i].cover;
      return newMangaData;
    });
  }

  void editMyMangaList(String status, int score, String volumeStr, String chapterStr) async{
    volumeStr = volumeStr.isEmpty ? '0' : volumeStr;
    chapterStr = chapterStr.isEmpty ? '0' : chapterStr;
    if(int.tryParse(volumeStr) == null || int.tryParse(chapterStr) == null){
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
    }else if((int.parse(volumeStr) > mangaData.totalVolumes && mangaData.totalVolumes > 0) || (int.parse(chapterStr) > mangaData.totalChapters && mangaData.totalChapters > 0)){
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
        status = 'reading';
      }
      var map = {
        'status': status,
        'score': score.toString(),
        'num_volumes_read': volumeStr,
        'num_chapters_read': chapterStr
      };
      var res = await dio.patch(
        '$malApiUrl/manga/${mangaData.id}/my_list_status',
        data: map,
        options: Options(
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            'Authorization': await generateAuthHeader()
          },
        ),
      );
      if(res.statusCode == 200){
        MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
        newMangaData.myListStatus = MangaMyListStatusClass.generateNewCopy(newMangaData.myListStatus);
        newMangaData.myListStatus!.volumesRead = int.parse(volumeStr);
        newMangaData.myListStatus!.chaptersRead = int.parse(chapterStr);
        newMangaData.myListStatus!.score = score;
        newMangaData.myListStatus!.updatedTime = DateTime.now().toIso8601String();
        newMangaData.myListStatus!.status = status;
        appStateClass.globalMangaData[mangaData.id]!.notifier.value = newMangaData;
        UpdateUserMangaListStreamClass().emitData(
          UserMangaListStreamControllerClass(
            newMangaData
          )
        );
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Successfully saved progress')
          ));
        }
      }
    }
  }

  void deleteFromMyMangaList() async{
    var res = await dio.delete(
      '$malApiUrl/manga/${mangaData.id}/my_list_status',
      options: Options(
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': await generateAuthHeader()
        },
      ),
    );
    if(res.statusCode == 200){
      MangaDataClass newMangaData = MangaDataClass.generateNewCopy(mangaData);
      newMangaData.myListStatus = null;
      appStateClass.globalMangaData[mangaData.id]!.notifier.value = newMangaData;
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully deleted from list')
        ));
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
                                chapterController.text = '${max(0, int.tryParse(chapterController.text) != null ? int.parse(chapterController.text) - 1 : 0)}';
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
  
  @override
  Widget build(BuildContext context) {
    double besideImageWidth = getScreenWidth() - animeDetailDisplayCoverSize.width - (getScreenWidth() * 0.03) - (defaultHorizontalPadding * 2);
    double fullWidth = getScreenWidth() - (defaultHorizontalPadding * 2);
    if(!widget.skeletonMode){
      MangaStatisticsClass statusStats = mangaData.statistics;
      int totalActivitiesCount = statusStats.reading + statusStats.completed + statusStats.dropped + statusStats.planToRead + statusStats.onHold;
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding,
          ),
          child: ListView(
            children: [
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
              ValueListenableBuilder(
                valueListenable: selectedTitle,
                builder: (context, selectedTitleValue, child){
                  String notice = '(No title provided)';
                  String title = '';
                  if(selectedTitleValue == SelectedTitle.main){
                    title = mangaData.title;
                  }else{
                    if(mangaData.alternativeTitles != null){
                      if(selectedTitleValue == SelectedTitle.english){
                        title = mangaData.alternativeTitles!.en;
                      }else if(selectedTitleValue == SelectedTitle.japanese){
                        title = mangaData.alternativeTitles!.ja;
                      }else{
                        title = notice;
                      }
                    }else{
                      title = notice;
                    }
                  }
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: (){
                              selectedTitle.value = SelectedTitle.main;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedTitleValue == SelectedTitle.main ? Colors.blueAccent : Colors.grey,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)
                                )
                              ),
                              width: getScreenWidth() * 0.2,
                              height: getScreenHeight() * 0.05,
                              child: const Center(
                                child: Text('Main')
                              )
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: (){
                              selectedTitle.value = SelectedTitle.english;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedTitleValue == SelectedTitle.english ? Colors.blueAccent : Colors.grey,
                              ),
                              width: getScreenWidth() * 0.2,
                              height: getScreenHeight() * 0.05,
                              child: const Center(
                                child: Text('ENG')
                              )
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: (){
                              selectedTitle.value = SelectedTitle.japanese;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedTitleValue == SelectedTitle.japanese ? Colors.blueAccent : Colors.grey,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15)
                                )
                              ),
                              width: getScreenWidth() * 0.2,
                              height: getScreenHeight() * 0.05,
                              child: const Center(
                                child: Text('JPN')
                              )
                            )
                          )
                        ],
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.0075
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.075,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: getScreenHeight() * 0.01),
                              child: Text(
                                title, 
                                style: TextStyle(
                                  fontSize: defaultTextFontSize * 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.center
                              )
                            )
                          )
                        )
                      )
                    ]
                  );
                }
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: animeDetailDisplayCoverSize.width,
                    height: animeDetailDisplayCoverSize.height,
                    child: generateCachedImage(mangaData.cover)
                  ),
                  SizedBox(
                    width: getScreenWidth() * 0.03
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Score', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${mangaData.mean ?? '-'}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Rank', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('#${mangaData.rank ?? '-'}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.01
                      ),
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Popularity', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('#${mangaData.popularity ?? '-'}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Listed', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text(convertNumberReadable(mangaData.listedCount), style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.01
                      ),
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Scored', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text(convertNumberReadable(mangaData.scoredCount), style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Type', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text(getFormattedMangaMediaType(mangaData.mediaType), style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.01
                      ),
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Volumes', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${mangaData.totalVolumes == 0 ? '-' : mangaData.totalVolumes}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Chapters', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${mangaData.totalChapters == 0 ? '-' : mangaData.totalChapters}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                          ]
                        )
                      )
                    ]
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              SizedBox(
                width: fullWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lime.withOpacity(0.475),
                        borderRadius: const BorderRadius.all(Radius.circular(12.5))
                      ),
                      width: fullWidth * 0.325,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Started at', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(
                            mangaData.startDate != null && DateTime.tryParse(mangaData.startDate!) != null ? convertDateTimeDisplay(mangaData.startDate!) : '-',
                            style: TextStyle(
                            fontSize: defaultTextFontSize * 0.925,
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                          ))
                        ],
                      ),
                    ),
                    SizedBox(
                      width: fullWidth * 0.025,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lime.withOpacity(0.475),
                        borderRadius: const BorderRadius.all(Radius.circular(12.5))
                      ),
                      width: fullWidth * 0.325,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Finished at', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(mangaData.endDate != null && DateTime.tryParse(mangaData.endDate!) != null ? convertDateTimeDisplay(mangaData.endDate!) : '-', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.925,
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                          ))
                        ],
                      ),
                    ),
                    SizedBox(
                      width: fullWidth * 0.025,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lime.withOpacity(0.475),
                        borderRadius: const BorderRadius.all(Radius.circular(12.5))
                      ),
                      width: fullWidth * 0.3,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Status', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(getMangaStatus(mangaData.status), style: TextStyle(
                            fontSize: defaultTextFontSize * 0.9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                          ))
                        ],
                      ),
                    )
                  ]
                )
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              mangaData.myListStatus != null ?
                CustomButton(
                  width: fullWidth, 
                  height: getScreenHeight() * 0.075, 
                  buttonColor: Colors.brown.withOpacity(0.4), 
                  buttonText: 'Edit in list', 
                  onTapped: () => openActionDrawer(), 
                  setBorderRadius: true
                )
              : 
                CustomButton(
                  width: fullWidth, 
                  height: getScreenHeight() * 0.075, 
                  buttonColor: Colors.brown.withOpacity(0.4), 
                  buttonText: 'Add to list', 
                  onTapped: () => openActionDrawer(), 
                  setBorderRadius: true
                ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Synopsis'),
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.03,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: Text(
                      mangaData.synopsis ?? '',
                      style: TextStyle(
                        fontSize: defaultTextFontSize * 0.95
                      )
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Background'),
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.03,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: Text(
                      mangaData.background ?? '',
                      style: TextStyle(
                        fontSize: defaultTextFontSize * 0.95
                      )
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Characters'),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.025,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for(int i = 0; i < min(detailImgWidgetMaxAmount, mangaData.characters.length); i++)
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                              horizontal: getScreenWidth() * 0.005,
                            ),
                            child: CustomBasicCharacterDisplay(
                              characterData: mangaData.characters[i], 
                              showStats: false,
                              skeletonMode: false
                            )
                          )
                        ]
                      )
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Genres'),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.025,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: getScreenHeight() * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for(int i = 0; i < mangaData.genres.length; i++)
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                horizontal: getScreenWidth() * 0.025,
                                vertical: getScreenHeight() * 0.0075,
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: getScreenWidth() * 0.005,
                                vertical: getScreenHeight() * 0.0025,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.4),
                                borderRadius: const BorderRadius.all(Radius.circular(10))
                              ),
                              child: Text(mangaData.genres[i].name)
                            )
                          ]
                        )
                      )
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Authors'),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.025,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: getScreenHeight() * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for(int i = 0; i < mangaData.authors.length; i++)
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                horizontal: getScreenWidth() * 0.025,
                                vertical: getScreenHeight() * 0.0075,
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: getScreenWidth() * 0.005,
                                vertical: getScreenHeight() * 0.0025,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.4),
                                borderRadius: const BorderRadius.all(Radius.circular(10))
                              ),
                              child: Text('${mangaData.authors[i].firstName} ${mangaData.authors[i].lastName} (${mangaData.authors[i].role})')
                            )
                          ]
                        )
                      )
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Pictures'),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.025,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: getScreenHeight() * 0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for(int i = 0; i < min(detailImgWidgetMaxAmount, mangaData.pictures.length); i++)
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(
                                horizontal: getScreenWidth() * 0.015,
                                vertical: getScreenHeight() * 0.0025,
                              ),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: SizedBox(
                                width: animeGridDisplayCoverSize.width,
                                height: animeGridDisplayCoverSize.height,
                                child: generateCachedImage(mangaData.pictures[i])
                              ),
                            )
                          ]
                        )
                      )
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Related Mangas'),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.025,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for(int i = 0; i < min(detailImgWidgetMaxAmount, relatedMangasData.length); i++)
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                              horizontal: getScreenWidth() * 0.005,
                            ),
                            child: CustomBasicMangaDisplay(
                              mangaData: relatedMangasData[i], 
                              showStats: false,
                              skeletonMode: false
                            )
                          )
                        ]
                      )
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('Statistics'),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.025,
                      vertical: getScreenHeight() * 0.02,
                    ),
                    child: generateBarChart(
                      [
                        VBarChartModel(
                          index: 0,
                          colors: [Colors.orange, Colors.orange],
                          jumlah: statusStats.reading.toDouble(),
                          tooltip: totalActivitiesCount == 0 ? '0%' : '${((statusStats.reading / totalActivitiesCount) * 100).roundToDouble().toString()}%'
                        ),
                        VBarChartModel(
                          index: 1,
                          colors: [Colors.red, Colors.red],
                          jumlah: statusStats.planToRead.toDouble(),
                          tooltip: totalActivitiesCount == 0 ? '0%' : '${((statusStats.planToRead / totalActivitiesCount) * 100).roundToDouble().toString()}%'
                        ),
                        VBarChartModel(
                          index: 2,
                          colors: [Colors.green, Colors.green],
                          jumlah: statusStats.completed.toDouble(),
                          tooltip: totalActivitiesCount == 0 ? '0%' : '${((statusStats.completed / totalActivitiesCount) * 100).roundToDouble().toString()}%'
                        ),
                        VBarChartModel(
                          index: 3,
                          colors: [Colors.cyan, Colors.cyan],
                          jumlah: statusStats.onHold.toDouble(),
                          tooltip: totalActivitiesCount == 0 ? '0%' : '${((statusStats.onHold / totalActivitiesCount) * 100).roundToDouble().toString()}%'
                        ),
                        VBarChartModel(
                          index: 4,
                          colors: [Colors.purple, Colors.purple],
                          jumlah: statusStats.dropped.toDouble(),
                          tooltip: totalActivitiesCount == 0 ? '0%' : '${((statusStats.dropped / totalActivitiesCount) * 100).roundToDouble().toString()}%'
                        )
                      ],
                      [
                        const Vlegend(
                          isSquare: false,
                          color: Colors.orange,
                          text: 'Reading'
                        ),
                        const Vlegend(
                          isSquare: false,
                          color: Colors.red,
                          text: 'Planning'
                        ),
                        const Vlegend(
                          isSquare: false,
                          color: Colors.green,
                          text: 'Completed'
                        ),
                        const Vlegend(
                          isSquare: false,
                          color: Colors.cyan,
                          text: 'On Hold'
                        ),
                        const Vlegend(
                          isSquare: false,
                          color: Colors.purple,
                          text: 'Dropped'
                        )
                      ],
                      totalActivitiesCount.toDouble()
                    )
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
            ],
          ),
        ),
      );
    }else{
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding,
          ),
          child: ListView(
            children: [
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15)
                          )
                        ),
                        width: getScreenWidth() * 0.2,
                        height: getScreenHeight() * 0.05
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                        ),
                        width: getScreenWidth() * 0.2,
                        height: getScreenHeight() * 0.05
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15)
                          )
                        ),
                        width: getScreenWidth() * 0.2,
                        height: getScreenHeight() * 0.05
                      )
                    ],
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.0075
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.075,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: getScreenHeight() * 0.01),
                      child: Container(
                        height: getScreenHeight() * 0.045,
                        color: Colors.grey,
                        width: fullWidth
                      )
                    )  
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: animeDetailDisplayCoverSize.width,
                    height: animeDetailDisplayCoverSize.height,
                    color: Colors.grey
                  ),
                  SizedBox(
                    width: getScreenWidth() * 0.03
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Score', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Rank', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.01
                      ),
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Popularity', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Listed', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.01
                      ),
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Scored', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Type', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.01
                      ),
                      SizedBox(
                        width: besideImageWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Volumes', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                            SizedBox(
                              width: besideImageWidth * 0.05,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lime.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: besideImageWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Chapters', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text('')
                                ],
                              ),
                            ),
                          ]
                        )
                      )
                    ]
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              SizedBox(
                width: fullWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lime.withOpacity(0.475),
                        borderRadius: const BorderRadius.all(Radius.circular(12.5))
                      ),
                      width: fullWidth * 0.325,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Started at', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          const Text('')
                        ],
                      ),
                    ),
                    SizedBox(
                      width: fullWidth * 0.025,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lime.withOpacity(0.475),
                        borderRadius: const BorderRadius.all(Radius.circular(12.5))
                      ),
                      width: fullWidth * 0.325,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Finished at', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          const Text('')
                        ],
                      ),
                    ),
                    SizedBox(
                      width: fullWidth * 0.025,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lime.withOpacity(0.475),
                        borderRadius: const BorderRadius.all(Radius.circular(12.5))
                      ),
                      width: fullWidth * 0.3,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Status', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          const Text('')
                        ],
                      ),
                    )
                  ]
                )
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              CustomButton(
                width: fullWidth, 
                height: getScreenHeight() * 0.075, 
                buttonColor: Colors.grey, 
                buttonText: '', 
                onTapped: (){}, 
                setBorderRadius: true
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Synopsis')
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Background')
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Characters')
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Genres')
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Authors')
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Pictures')
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Related Mangas')
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Statistics')
              ),
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
            ],
          ),
        ),
      );
    }
  }

}