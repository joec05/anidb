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