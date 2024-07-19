import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart' as intl;

int getAnimeBasicDisplayFetchCount(){
  return (getScreenWidth() / basicDisplayWidgetSize.width).floor() * 5;
}

int getAnimeBasicDisplayTotalFetchCount(){
  return (getScreenWidth() / basicDisplayWidgetSize.width).floor() * 25;
}

int getAnimeBasicDisplayCrossAxis(){
  return (getScreenWidth() / basicDisplayWidgetSize.width).floor();
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

String getFormattedAnimeMediaType(String str){
  if(str.isEmpty){
    return str;
  }
  if(str == 'tv' || str == 'ova' || str == 'ona'){
    return str.toUpperCase();
  }else{
    return '${str[0].toUpperCase()}${str.substring(1).split('_').join(' ')}';
  }
}

String getFormattedSource(String str){
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