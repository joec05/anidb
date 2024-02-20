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