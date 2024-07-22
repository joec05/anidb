import 'package:anidb/global_files.dart';

class UserMangaListStatusClass{
  List<MangaDataClass> mangaList;
  String status;
  bool canPaginate;
  PaginationStatus paginationStatus;

  UserMangaListStatusClass(
    this.mangaList,
    this.status,
    this.canPaginate,
    this.paginationStatus
  );

  UserMangaListStatusClass copy() {
    return UserMangaListStatusClass(
      mangaList,
      status,
      canPaginate,
      paginationStatus
    );
  }

  UserMangaListStatusClass updatePaginationStatus(PaginationStatus paginationStatus) {
    return UserMangaListStatusClass(
      mangaList, 
      status, 
      canPaginate, 
      paginationStatus
    );
  }

  UserMangaListStatusClass updateCanPaginate(bool canPaginate) {
    return UserMangaListStatusClass(
      mangaList, 
      status, 
      canPaginate, 
      paginationStatus
    );
  }
}