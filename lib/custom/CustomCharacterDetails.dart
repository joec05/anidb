// ignore_for_file: use_build_context_synchronously
import 'dart:math';

import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/class/AnimeDataClass.dart';
import 'package:anime_list_app/class/CharacterDataClass.dart';
import 'package:anime_list_app/class/MangaDataClass.dart';
import 'package:anime_list_app/custom/CustomBasicAnimeDisplay.dart';
import 'package:anime_list_app/custom/CustomBasicMangaDisplay.dart';
import 'package:anime_list_app/custom/CustomBasicVoiceDisplay.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:flutter/material.dart';

class CustomCharacterDetails extends StatefulWidget {
  final CharacterDataClass characterData;
  final bool skeletonMode;

  const CustomCharacterDetails({
    super.key,
    required this.characterData,
    required this.skeletonMode
  });

  @override
  State<CustomCharacterDetails> createState() => CustomCharacterDetailsState();
}

class CustomCharacterDetailsState extends State<CustomCharacterDetails>{
  late CharacterDataClass characterData;
  ValueNotifier<SelectedCharacterName> selectedName = ValueNotifier(SelectedCharacterName.main);
  List<AnimeDataClass> animesData = [];
  List<MangaDataClass> mangasData = [];

  @override void dispose(){
    super.dispose();
    selectedName.dispose();
  }

  @override void initState(){
    super.initState();
    characterData = widget.characterData;
    animesData = List.generate(characterData.animes.length, (i){
      AnimeDataClass newAnimeData = AnimeDataClass.fetchNewInstance(characterData.animes[i].animeID);
      newAnimeData.title = characterData.animes[i].animeTitle;
      newAnimeData.cover = characterData.animes[i].animeCover;
      return newAnimeData;
    });
    mangasData = List.generate(characterData.mangas.length, (i){
      MangaDataClass newMangaData = MangaDataClass.fetchNewInstance(characterData.mangas[i].mangaID);
      newMangaData.title = characterData.mangas[i].mangaTitle;
      newMangaData.cover = characterData.mangas[i].mangaCover;
      return newMangaData;
    });
  }

  @override
  Widget build(BuildContext context) {
    double besideImageWidth = getScreenWidth() - animeDetailDisplayCoverSize.width - (getScreenWidth() * 0.03) - (defaultHorizontalPadding * 2);
    if(!widget.skeletonMode){
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
                valueListenable: selectedName,
                builder: (context, selectedNameValue, child){
                  String notice = '(No name provided)';
                  String name = '';
                  if(selectedNameValue == SelectedCharacterName.main){
                    name = characterData.name;
                  }else{
                    if(characterData.kanjiName != null){
                      if(selectedNameValue == SelectedCharacterName.kanji){
                        name = characterData.kanjiName!;
                      }else{
                        name = notice;
                      }
                    }else{
                      name = notice;
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
                              selectedName.value = SelectedCharacterName.main;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedNameValue == SelectedCharacterName.main ? Colors.blueAccent : Colors.grey,
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
                              selectedName.value = SelectedCharacterName.kanji;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedNameValue == SelectedCharacterName.kanji ? Colors.blueAccent : Colors.grey,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15)
                                )
                              ),
                              width: getScreenWidth() * 0.2,
                              height: getScreenHeight() * 0.05,
                              child: const Center(
                                child: Text('Kanji')
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
                                name, 
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
                    child: characterData.cover.large != null ? Image.network(characterData.cover.large!, fit: BoxFit.cover) : Image.asset("assets/images/anime-no-image.png", fit: BoxFit.cover)
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
                                  Text('Favorites', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${characterData.favouritedCount}', style: TextStyle(
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
                                  Text('Animes', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${characterData.animes.length}', style: TextStyle(
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
                                  Text('Mangas', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${characterData.mangas.length}', style: TextStyle(
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
                                  Text('Voices', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${characterData.voices.length}', style: TextStyle(
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
                    ]
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              ExpansionTile(
                title: const Text('About'),
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: getScreenWidth() * 0.03,
                      vertical: getScreenHeight() * 0.01,
                    ),
                    child: Text(
                      characterData.about ?? '',
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
                title: const Text('Animes'),
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
                          for(int i = 0; i < min(detailImgWidgetMaxAmount, animesData.length); i++)
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                              horizontal: getScreenWidth() * 0.005,
                            ),
                            child: CustomBasicAnimeDisplay(
                              animeData: animesData[i], 
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
                title: const Text('Mangas'),
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
                          for(int i = 0; i < min(detailImgWidgetMaxAmount, mangasData.length); i++)
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                              horizontal: getScreenWidth() * 0.005,
                            ),
                            child: CustomBasicMangaDisplay(
                              mangaData: mangasData[i], 
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
                title: const Text('Voices'),
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
                          for(int i = 0; i < min(detailImgWidgetMaxAmount, characterData.voices.length); i++)
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(
                              horizontal: getScreenWidth() * 0.005,
                            ),
                            child: CustomBasicVoiceDisplay(
                              voiceData: characterData.voices[i], 
                            )
                          )
                        ]
                      )
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
      double fullWidth = getScreenWidth() - (defaultHorizontalPadding) * 2;
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
                        height: getScreenHeight() * 0.05,
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
                        height: getScreenHeight() * 0.05,
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
                                  Text('Favorites', style: TextStyle(
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
                                  Text('Animes', style: TextStyle(
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
                                  Text('Mangas', style: TextStyle(
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
                                  Text('Voices', style: TextStyle(
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
                    ]
                  )
                ]
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('About'),
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Animes'),
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Mangas'),
              ),
              SizedBox(
                height: getScreenHeight() * 0.0125
              ),
              const ExpansionTile(
                title: Text('Voices'),
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