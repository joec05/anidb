import 'package:anime_list_app/appdata/global_enums.dart';

class UserAnimeListStatusClass{
  List<int> animesList;
  String status;
  bool canPaginate;
  PaginationStatus paginationStatus;

  UserAnimeListStatusClass(
    this.animesList,
    this.status,
    this.canPaginate,
    this.paginationStatus
  );
}