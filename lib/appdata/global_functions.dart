import 'dart:math';
import 'dart:ui';
import 'package:anime_list_app/appdata/global_variables.dart';
import 'package:anime_list_app/appdata/private_data.dart';
import 'package:anime_list_app/class/user_token_class.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timezone/timezone.dart' as tz;

double getScreenHeight(){
  return PlatformDispatcher.instance.views.first.physicalSize.height / PlatformDispatcher.instance.views.first.devicePixelRatio;
}

double getScreenWidth(){
  return PlatformDispatcher.instance.views.first.physicalSize.width / PlatformDispatcher.instance.views.first.devicePixelRatio;
}

void runDelay(Function func, int duration) async{
  Future.delayed(Duration(milliseconds: duration), (){ }).then((value){
    func();
  });
}

Future<String> generateAuthHeader() async{
  UserTokenClass tokenData = appStateClass.userTokenData;
  DateTime expiryTimeParsed = DateTime.parse(tokenData.expiryTime);
  int differenceInHour = expiryTimeParsed.difference(DateTime.now()).inHours;
  debugPrint('$differenceInHour hours before refreshing token');
  if(differenceInHour <= 36){
    var res = await dio.post(
      'https://myanimelist.net/v1/oauth2/token',
      data: {
        'client_id': clientID,
        'grant_type': 'refresh_token',
        'refresh_token': tokenData.refreshToken,
      },
      options: Options(
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      )
    );
    var data = res.data;
    appStateClass.userTokenData = UserTokenClass.fromMapUpdate(data);
    appStateClass.appStorage.updateUserToken();
  }
  return 'Bearer ${appStateClass.userTokenData.accessToken}';
}

String convertDateTimeDisplay(String dateTime){
  List<String> separatedDateTime = DateTime.parse(dateTime).toLocal().toIso8601String().substring(0, 10).split('-').reversed.toList();
  List<String> months = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  separatedDateTime[1] = months[int.parse(separatedDateTime[1])];
  return separatedDateTime.join(' ');
}

int getAnimeBasicDisplayFetchCount(){
  return (getScreenWidth() / animeGridDisplayWidgetSize.width).floor() * 5;
}

int getAnimeBasicDisplayTotalFetchCount(){
  return (getScreenWidth() / animeGridDisplayWidgetSize.width).floor() * 25;
}

int getAnimeBasicDisplayCrossAxis(){
  return (getScreenWidth() / animeGridDisplayWidgetSize.width).floor();
}

String getCurrentSeason(){
  int month = DateTime.now().month;
  if(month >= 1 && month <= 3){
    return 'winter';
  }else if(month >= 4 && month <= 6){
    return 'spring';
  }else if(month >= 7 && month <= 9){
    return 'summer';
  }else if(month >= 10 && month <= 12){
    return 'fall';
  }
  return '';
}

String getAnimeStatus(String str){
  if(str == 'finished_airing'){
    return 'Finished';
  }else if(str == 'currently_airing'){
    return 'Ongoing';
  }else{
    return 'Upcoming';
  }
}

String getMangaStatus(String str){
  if(str == 'finished'){
    return 'Finished';
  }else if(str == 'currently_publishing'){
    return 'Ongoing';
  }else{
    return 'Upcoming';
  }
}

String getFormattedAnimeMediaType(String str){
  if(str.isEmpty){
    return str;
  }
  if(str == 'tv' || str == 'ova' || str == 'ona'){
    return str.toUpperCase();
  }else{
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }
}

String getFormattedMangaMediaType(String str){
  if(str.isEmpty){
    return str;
  }
  if(str == 'oel'){
    return str.toUpperCase();
  }else if(str == 'one_shot' || str == 'light_novel'){
    List<String> words = str.split('_');
    words[0] = '${words[0][0].toUpperCase()}${words[0].substring(1)}';
    return words.join(' ');
  }else{
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }
}

String getShortenedNumbers(int int){
  if(int >= 1000){
    return '${(int / 1000).floor()}${((int % 1000) / 100).floor() > 0 ? '.${((int % 1000) / 100).floor()}' : ''}K';
  }else if(int >= 100000){
    return '${(int / 1000).floor()}K';
  }else if(int >= 1000000){
    return '${(int / 1000000).floor()}${((int % 1000000) / 100000).floor() > 0 ? '.${((int % 1000000) / 100000).floor()}' : ''}M';
  }else if(int >= 100000000){
    return '${(int / 10000000).floor()}M';
  }
  return int.toString();
}

String convertNumberReadable(int int){
  List<String> integers = int.toString().split('');
  if(int > 1000000){
    integers.insert(4, ',');
    integers.insert(1, ',');
  }else if(int > 100000){
    integers.insert(3, ',');
  }else if(int > 10000){
    integers.insert(2, ',');
  }else if(int > 1000){
    integers.insert(1, ',');
  }
  return integers.join('');
}

String? parseDateToShortText(String str){
  List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  DateTime? parsed = DateTime.tryParse(str);
  if(parsed == null){
    return null;
  }
  int month = parsed.month;
  int year = parsed.year;
  return '${months[month - 1]} $year';
}

String getFormattedAnimeSource(String str){
  if(str.contains('_')){
    List<String> words = str.split('_');
    if(int.tryParse(words[0][0]) != null){
      return words.join(' ');
    }else{
      words[0] = '${words[0][0].toUpperCase()}${words[0].substring(1)}';
      return words.join(' ');
    }
  }else{
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }
}

String getLocalBroadcastTime(String time, String day){
  List<String> weeks = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  int getDayIndex = weeks.indexWhere((element) => day.contains(element.toLowerCase()));
  int originalHour = int.parse(time.split(':')[0]);
  final DateTime now = DateTime.now().toLocal();
  final tz.Location japan = tz.getLocation('Asia/Tokyo');
  final tz.TZDateTime japanTimeNow = tz.TZDateTime.from(now, japan);
  final int differenceInHour = now.hour - japanTimeNow.hour;
  DateTime dateFormat = intl.DateFormat('HH:mm').parse(time).add(Duration(hours: differenceInHour));
  int formattedHour = dateFormat.hour;
  String resDay = '';
  if(differenceInHour > 0 && originalHour > formattedHour){
    resDay = weeks[(getDayIndex + 1) % weeks.length];
  }else if(differenceInHour < 0 && originalHour < formattedHour){
    resDay = weeks[max(0, getDayIndex - 1)];
  }else{
    resDay = weeks[getDayIndex];
  }
  return '$resDay, $formattedHour:${time.split(':')[1]} (${DateTime.now().timeZoneName})';
}
