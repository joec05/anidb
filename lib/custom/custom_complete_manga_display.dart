import 'dart:math';
import 'package:anime_list_app/view_manga_details.dart';
import 'package:anime_list_app/appdata/global_enums.dart';
import 'package:anime_list_app/appdata/global_functions.dart';
import 'package:anime_list_app/appdata/global_variables.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/class/manga_my_list_status_class.dart';
import 'package:anime_list_app/custom/custom_button.dart';
import 'package:anime_list_app/extensions/string_ellipsis.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/streams/update_user_manga_list_stream.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:anime_list_app/transition/navigation_transition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomUserListMangaDisplay extends StatefulWidget {
  final MangaDataClass mangaData;
  final MangaRowDisplayType displayType;
  final bool skeletonMode;

  const CustomUserListMangaDisplay({
    super.key,
    required this.mangaData,
    required this.displayType,
    required this.skeletonMode
  });

  @override
  State<CustomUserListMangaDisplay> createState() => CustomUserListMangaDisplayState();
}

class CustomUserListMangaDisplayState extends State<CustomUserListMangaDisplay>{
  late MangaDataClass mangaData;

  @override void initState(){
    super.initState();
    mangaData = widget.mangaData;
  }

  @override void dispose(){
    super.dispose();
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
  
  @override
  Widget build(BuildContext context) {
    if(!widget.skeletonMode){
      if(mangaData.myListStatus == null && widget.displayType == MangaRowDisplayType.myUserList){
        return Container();
      }
      return GestureDetector(
        onTap: (){
          runDelay(() => Navigator.push(
            context,
            NavigationTransition(
              page: ViewMangaDetails(
                mangaID: mangaData.id
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
                      child: generateCachedImage(mangaData.cover)
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
                                        StringEllipsis.convertToEllipsis(mangaData.title), 
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
                                          child: Text('${mangaData.mean ?? '-'}', style: TextStyle(
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
                                          child: Text('#${mangaData.rank ?? '-'}', style: TextStyle(
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
                                          child: Text('#${mangaData.popularity ?? '-'}', style: TextStyle(
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
                                    Text(getFormattedMangaMediaType(mangaData.mediaType), style: TextStyle(
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
                                    mangaData.startDate != null ? parseDateToShortText(mangaData.startDate!) != null?
                                      Row(
                                        children: [
                                          Text(parseDateToShortText(mangaData.startDate!)!, style: TextStyle(
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
                                    Text(getMangaStatus(mangaData.status), style: TextStyle(
                                      fontSize: defaultTextFontSize * 0.9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500
                                    )),
                                  ],
                                ),
                                SizedBox(
                                  height: getScreenHeight() * 0.01
                                ),
                                mangaData.myListStatus != null ?
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
                                    StringEllipsis.convertToEllipsis(mangaData.genres.map((e) => e.name).toList().join(', ')), 
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