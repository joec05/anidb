String getMangaStatus(String str){
  if(str == 'finished'){
    return 'Finished';
  }else if(str == 'currently_publishing'){
    return 'Ongoing';
  }else{
    return 'Upcoming';
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