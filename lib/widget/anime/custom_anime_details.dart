import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class CustomAnimeDetails extends StatefulWidget {
  final AnimeDataClass animeData;
  final bool skeletonMode;

  const CustomAnimeDetails({
    super.key,
    required this.animeData,
    required this.skeletonMode
  });

  @override
  State<CustomAnimeDetails> createState() => CustomAnimeDetailsState();
}

class CustomAnimeDetailsState extends State<CustomAnimeDetails>{
  late AnimeDataClass animeData;
  ValueNotifier<SelectedTitle> selectedTitle = ValueNotifier(SelectedTitle.main);
  List<AnimeDataClass> relatedAnimesData = [];

  @override void initState(){
    super.initState();
    animeData = widget.animeData;
    relatedAnimesData = List.generate(animeData.relatedAnimes.length, (i){
      AnimeDataClass newAnimeData = AnimeDataClass.fetchNewInstance(animeData.relatedAnimes[i].id);
      newAnimeData.title = animeData.relatedAnimes[i].title;
      newAnimeData.cover = animeData.relatedAnimes[i].cover;
      return newAnimeData;
    });
  }

  @override void dispose(){
    super.dispose();
    selectedTitle.dispose();
  }

  void editMyAnimeList(String status, int score, String episodeStr) async{
    episodeStr = episodeStr.isEmpty ? '0' : episodeStr;
    if(int.tryParse(episodeStr) == null){
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
        'num_watched_episodes': episodeStr
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
            content: Text('Successfully saved progress')
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
  
  @override
  Widget build(BuildContext context) {
    double besideImageWidth = getScreenWidth() - animeDetailDisplayCoverSize.width - (getScreenWidth() * 0.03) - (defaultHorizontalPadding * 2);
    double fullWidth = getScreenWidth() - (defaultHorizontalPadding * 2);
    if(!widget.skeletonMode){
      AnimeStatisticsClass statusStats = animeData.statistics;
      int totalActivitiesCount = statusStats.watching + statusStats.completed + statusStats.dropped + statusStats.planToWatch + statusStats.onHold;
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
                    title = animeData.title;
                  }else{
                    if(animeData.alternativeTitles != null){
                      if(selectedTitleValue == SelectedTitle.english){
                        title = animeData.alternativeTitles!.en ?? notice;
                      }else if(selectedTitleValue == SelectedTitle.japanese){
                        title = animeData.alternativeTitles!.ja ?? notice;
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
                    child: generateCachedImage(animeData.cover)
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
                                  Text('${animeData.mean ?? '-'}', style: TextStyle(
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
                                  Text('#${animeData.rank ?? '-'}', style: TextStyle(
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
                                  Text('#${animeData.popularity ?? '-'}', style: TextStyle(
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
                                  Text(convertNumberReadable(animeData.listedCount), style: TextStyle(
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
                                  Text(convertNumberReadable(animeData.scoredCount), style: TextStyle(
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
                                  Text(getFormattedAnimeMediaType(animeData.mediaType), style: TextStyle(
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
                                  Text('Status', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text(getAnimeStatus(animeData.status), style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.9,
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
                                  Text('Episodes', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${animeData.totalEpisodes == 0 ? '-' : animeData.totalEpisodes}', style: TextStyle(
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
                          Text('Aired at', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(
                            animeData.startDate != null && DateTime.tryParse(animeData.startDate!) != null ? convertDateTimeDisplay(animeData.startDate!) : '-',
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
                          Text(animeData.endDate != null && DateTime.tryParse(animeData.endDate!) != null ? convertDateTimeDisplay(animeData.endDate!) : '-', style: TextStyle(
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
                          Text('Duration', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(animeData.averageDurationPerEps != null ? '${animeData.averageDurationPerEps! ~/ 60}m' : '-', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.925,
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
                      width: fullWidth * 0.4,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Broadcast', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(
                            animeData.broadcast != null ? animeData.broadcast!.startTime != null ?
                              getLocalBroadcastTime(animeData.broadcast!.startTime!, animeData.broadcast!.day)
                            : '-' : '-', 
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
                      width: fullWidth * 0.25,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Rating', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(animeData.rating ?? '-', style: TextStyle(
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
                          Text('Original', style: TextStyle(
                            fontSize: defaultTextFontSize * 0.825,
                            fontWeight: FontWeight.w400
                          )),
                          SizedBox(
                            height: getScreenHeight() * 0.005,
                          ),
                          Text(animeData.source != null ? getFormattedAnimeSource(animeData.source!) : '-', style: TextStyle(
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
                height: getScreenHeight() * 0.0125
              ),
              animeData.myListStatus != null ?
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
                      animeData.synopsis ?? '',
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
                      animeData.background ?? '',
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
                          for(int i = 0; i < min(detailImgWidgetMaxAmount, animeData.characters.length); i++)
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                              horizontal: getScreenWidth() * 0.005,
                            ),
                            child: CustomBasicCharacterDisplay(
                              characterData: animeData.characters[i], 
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
                            for(int i = 0; i < animeData.genres.length; i++)
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
                              child: Text(animeData.genres[i].name)
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
                title: const Text('Studios'),
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
                            for(int i = 0; i < animeData.studios.length; i++)
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
                              child: Text(animeData.studios[i].name)
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
                            for(int i = 0; i < min(detailImgWidgetMaxAmount, animeData.pictures.length); i++)
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
                                child: generateCachedImage(animeData.pictures[i])
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
                title: const Text('Related Animes'),
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
                          for(int i = 0; i < min(detailImgWidgetMaxAmount, relatedAnimesData.length); i++)
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                              horizontal: getScreenWidth() * 0.005,
                            ),
                            child: CustomBasicAnimeDisplay(
                              animeData: relatedAnimesData[i], 
                              showStats: false,
                              skeletonMode: false,
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
                          jumlah: statusStats.watching.toDouble(),
                          tooltip: totalActivitiesCount == 0 ? '0%' : '${((statusStats.watching / totalActivitiesCount) * 100).roundToDouble().toString()}%'
                        ),
                        VBarChartModel(
                          index: 1,
                          colors: [Colors.red, Colors.red],
                          jumlah: statusStats.planToWatch.toDouble(),
                          tooltip: totalActivitiesCount == 0 ? '0%' : '${((statusStats.planToWatch / totalActivitiesCount) * 100).roundToDouble().toString()}%'
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
                          text: 'Watching'
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (){
                          selectedTitle.value = SelectedTitle.main;
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15)
                            )
                          ),
                          width: getScreenWidth() * 0.2,
                          height: getScreenHeight() * 0.05,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (){
                          selectedTitle.value = SelectedTitle.english;
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                          width: getScreenWidth() * 0.2,
                          height: getScreenHeight() * 0.05,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (){
                          selectedTitle.value = SelectedTitle.japanese;
                        },
                        child: Container(
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
                                  Text('Episodes', style: TextStyle(
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
                          Text('Aired at', style: TextStyle(
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
                          Text('Duration', style: TextStyle(
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
                      width: fullWidth * 0.4,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Broadcast', style: TextStyle(
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
                      width: fullWidth * 0.25,
                      height: getScreenHeight() * 0.09,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Rating', style: TextStyle(
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
                          Text('Original', style: TextStyle(
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
                title: Text('Studios')
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
                title: Text('Related Animes')
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