import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

var dio = Dio();

var navigatorDelayTime = 0;

var actionDelayTime = 350;

IconData defaultBackIcon = Icons.arrow_back_ios;

String redirectUrl = 'https://myanimelist.net/';

String malApiUrl = 'https://api.myanimelist.net/v2';

String jikanApiUrl = 'https://api.jikan.moe/v4';

String userTokenClassDataKey = 'user-token-data';

int searchFetchLimit = 50;

int userDisplayFetchLimit = 25;

String fetchAllAnimeFieldsStr = 'fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,pictures,background,related_anime,related_manga,recommendations,studios,statistics';

String fetchAllMangaFieldsStr = 'fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_volumes,num_chapters,authors{first_name,last_name},pictures,background,related_anime,related_manga,recommendations,serialization{name}';

Map animeStatusMap = {
  'watching': 'Watching',
  'plan_to_watch': 'Planning',
  'completed': 'Completed',
  'on_hold': 'On hold',
  'dropped': 'Dropped',
};

Map mangaStatusMap = {
  'reading': 'Reading',
  'plan_to_read': 'Planning',
  'completed': 'Completed',
  'on_hold': 'On hold',
  'dropped': 'Dropped',
};

int detailImgWidgetMaxAmount = 25;

int skeletonLoadingDefaultLimit = 10;

String iconImageUrl = 'assets/images/icon.png';

int statsFetchLimit = 1000;