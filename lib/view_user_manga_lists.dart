import 'dart:async';
import 'package:anime_list_app/appdata/app_state_actions.dart';
import 'package:anime_list_app/appdata/global_library.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/class/user_manga_list_status_class.dart';
import 'package:anime_list_app/custom/custom_pagination.dart';
import 'package:anime_list_app/custom/custom_complete_manga_display.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/streams/update_user_manga_list_stream.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ViewUserMangaLists extends StatelessWidget {
  const ViewUserMangaLists({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ViewUserMangaListsStateful();
  }
}

class _ViewUserMangaListsStateful extends StatefulWidget {
  const _ViewUserMangaListsStateful();

  @override
  State<_ViewUserMangaListsStateful> createState() => _ViewUserMangaListsStatefulState();
}

class _ViewUserMangaListsStatefulState extends State<_ViewUserMangaListsStateful> with SingleTickerProviderStateMixin{
  UserMangaListStatusClass reading = UserMangaListStatusClass(
    [], 'reading', false, PaginationStatus.loaded
  );
  UserMangaListStatusClass planning = UserMangaListStatusClass(
    [], 'plan_to_read', false, PaginationStatus.loaded
  );
  UserMangaListStatusClass completed = UserMangaListStatusClass(
    [], 'completed', false, PaginationStatus.loaded
  );
  UserMangaListStatusClass dropped = UserMangaListStatusClass(
    [], 'dropped', false, PaginationStatus.loaded
  );
  UserMangaListStatusClass onHold = UserMangaListStatusClass(
    [], 'on_hold', false, PaginationStatus.loaded
  );
  bool isLoading = true;
  late TabController _tabController;
  late StreamSubscription updateUserMangaListStreamClassSubscription;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    fetchUserMangasList(reading);
    fetchUserMangasList(planning);
    fetchUserMangasList(completed);
    fetchUserMangasList(dropped);
    fetchUserMangasList(onHold);
    updateUserMangaListStreamClassSubscription = UpdateUserMangaListStreamClass().userMangaListStream.listen((UserMangaListStreamControllerClass data) {
      if(mounted){
        int id = data.mangaData.id;
        String status = data.mangaData.myListStatus!.status!; 

        reading.mangasList.remove(id);
        planning.mangasList.remove(id);
        completed.mangasList.remove(id);
        dropped.mangasList.remove(id);
        onHold.mangasList.remove(id);

        if(status == 'reading'){
          reading.mangasList.insert(0, id);
        }else if(status == 'plan_to_read'){
          planning.mangasList.insert(0, id);
        }else if(status == 'completed'){
          completed.mangasList.insert(0, id);
        }else if(status == 'dropped'){
          dropped.mangasList.insert(0, id);
        }else if(status == 'on_hold'){
          onHold.mangasList.insert(0, id);
        }
        if(mounted){
          setState((){});
        }
      }
    });
  }

  @override void dispose(){
    super.dispose();
    _tabController.dispose();
    updateUserMangaListStreamClassSubscription.cancel();
  }

  void fetchUserMangasList(UserMangaListStatusClass statusClass) async{
    if(mounted){
      if(!isLoading){
        setState(() => statusClass.paginationStatus = PaginationStatus.loading);
      }
    }
    var res = await dio.get(
      '$malApiUrl/users/@me/mangalist?status=${statusClass.status}&offset=${statusClass.mangasList.length}&limit=$userDisplayFetchLimit&$fetchAllMangaFieldsStr',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    if(res.statusCode == 200){
      statusClass.canPaginate = res.data['paging']['next'] != null;
      var data = res.data['data'];
      for(int i = 0; i < data.length; i++){
        updateMangaData(data[i]['node']);
        int id = data[i]['node']['id'];
        if(appStateClass.globalMangaData[id] != null){
        if(appStateClass.globalMangaData[id]!.notifier.value.myListStatus != null){
          String? status = appStateClass.globalMangaData[id]!.notifier.value.myListStatus!.status;
          if(status == 'reading'){
            reading.mangasList.add(id);
          }else if(status == 'plan_to_read'){
            planning.mangasList.add(id);
          }else if(status == 'completed'){
            completed.mangasList.add(id);
          }else if(status == 'on_hold'){
            onHold.mangasList.add(id);
          }else if(status == 'dropped'){
            dropped.mangasList.add(id);
          }
        }
      }
      }
      if(isLoading){
        isLoading = false;
      }else{
        statusClass.paginationStatus = PaginationStatus.loaded;
      }
      if(mounted){
        setState((){});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<UserMangaListStatusClass> lists = [
      reading, planning, completed, onHold, dropped
    ];
    return Scaffold(
      appBar: AppBar(
        leading: defaultLeadingWidget(context),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Manga List'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, bool f) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true, 
                expandedHeight: 50,
                pinned: true,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  onTap: (selectedIndex) {
                  },
                  isScrollable: true,
                  controller: _tabController,
                  labelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Reading'),
                    Tab(text: 'Planning'),
                    Tab(text: 'Completed'),
                    Tab(text: 'On Hold'),
                    Tab(text: 'Dropped')
                  ],                           
                )
              )
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            for(int x = 0; x < lists.length; x++)
            Builder(
              builder: (context) {
                return LoadMoreBottom(
                  addBottomSpace: lists[x].canPaginate,
                  loadMore: () async{
                    if(lists[x].canPaginate){
                      lists[x].paginationStatus = PaginationStatus.loading;
                      fetchUserMangasList(lists[x]);
                    }
                  },
                  status: lists[x].paginationStatus,
                  refresh: null,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)
                      ),
                      isLoading == true ?
                        SliverList(delegate: SliverChildBuilderDelegate(
                          childCount: skeletonLoadingDefaultLimit, 
                          (c, i) {
                            return shimmerSkeletonWidget(
                              CustomUserListMangaDisplay(
                                mangaData: MangaDataClass.fetchNewInstance(-1),
                                displayType: MangaRowDisplayType.myUserList,
                                skeletonMode: true,
                                key: UniqueKey()
                              )
                            );
                          }
                        ))
                      :
                        SliverList(delegate: SliverChildBuilderDelegate(
                          childCount: lists[x].mangasList.length, 
                          (c, i) {
                            return ValueListenableBuilder(
                              valueListenable: appStateClass.globalMangaData[lists[x].mangasList[i]]!.notifier, 
                              builder: (context, mangaData, child){
                                return CustomUserListMangaDisplay(
                                  mangaData: mangaData,
                                  displayType: MangaRowDisplayType.myUserList,
                                  skeletonMode: false,
                                  key: UniqueKey()
                                );
                              }
                            );
                          }
                        ))
                    ]
                  )
                );
              }
            )
          ]
        )
      )
    );
  }
}