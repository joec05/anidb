import 'dart:async';
import 'package:anime_list_app/appdata/app_state_actions.dart';
import 'package:anime_list_app/appdata/global_library.dart';
import 'package:anime_list_app/class/anime_data_class.dart';
import 'package:anime_list_app/class/user_anime_list_status_class.dart';
import 'package:anime_list_app/custom/custom_pagination.dart';
import 'package:anime_list_app/custom/custom_complete_anime_display.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/streams/update_user_anime_list_stream.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ViewUserAnimesList extends StatelessWidget {
  const ViewUserAnimesList({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ViewUserAnimesListStateful();
  }
}

class _ViewUserAnimesListStateful extends StatefulWidget {
  const _ViewUserAnimesListStateful();

  @override
  State<_ViewUserAnimesListStateful> createState() => _ViewUserAnimesListStatefulState();
}

class _ViewUserAnimesListStatefulState extends State<_ViewUserAnimesListStateful> with SingleTickerProviderStateMixin{
  UserAnimeListStatusClass watching = UserAnimeListStatusClass(
    [], 'watching', false, PaginationStatus.loaded
  );
  UserAnimeListStatusClass planning = UserAnimeListStatusClass(
    [], 'plan_to_watch', false, PaginationStatus.loaded
  );
  UserAnimeListStatusClass completed = UserAnimeListStatusClass(
    [], 'completed', false, PaginationStatus.loaded
  );
  UserAnimeListStatusClass dropped = UserAnimeListStatusClass(
    [], 'dropped', false, PaginationStatus.loaded
  );
  UserAnimeListStatusClass onHold = UserAnimeListStatusClass(
    [], 'on_hold', false, PaginationStatus.loaded
  );
  bool isLoading = true;
  late TabController _tabController;
  late StreamSubscription updateUserAnimeListStreamClassSubscription;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    fetchUserAnimesList(watching);
    fetchUserAnimesList(planning);
    fetchUserAnimesList(completed);
    fetchUserAnimesList(dropped);
    fetchUserAnimesList(onHold);
    updateUserAnimeListStreamClassSubscription = UpdateUserAnimeListStreamClass().userAnimeListStream.listen((UserAnimeListStreamControllerClass data) {
      if(mounted){
        int id = data.animeData.id;
        String status = data.animeData.myListStatus!.status!; 

        watching.animesList.remove(id);
        planning.animesList.remove(id);
        completed.animesList.remove(id);
        dropped.animesList.remove(id);
        onHold.animesList.remove(id);

        if(status == 'watching'){
          watching.animesList.insert(0, id);
        }else if(status == 'plan_to_watch'){
          planning.animesList.insert(0, id);
        }else if(status == 'completed'){
          completed.animesList.insert(0, id);
        }else if(status == 'dropped'){
          dropped.animesList.insert(0, id);
        }else if(status == 'on_hold'){
          onHold.animesList.insert(0, id);
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
    updateUserAnimeListStreamClassSubscription.cancel();
  }
  
  void fetchUserAnimesList(UserAnimeListStatusClass statusClass) async{
    if(mounted){
      if(!isLoading){
        setState(() => statusClass.paginationStatus = PaginationStatus.loading);
      }
    }
    var res = await dio.get(
      '$malApiUrl/users/@me/animelist?status=${statusClass.status}&offset=${statusClass.animesList.length}&limit=$userDisplayFetchLimit&$fetchAllAnimeFieldsStr',
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
        updateAnimeData(data[i]['node']);
        int id = data[i]['node']['id'];
        if(appStateClass.globalAnimeData[id] != null){
          if(appStateClass.globalAnimeData[id]!.notifier.value.myListStatus != null){
            String? status = appStateClass.globalAnimeData[id]!.notifier.value.myListStatus!.status;
            if(status == 'watching'){
              watching.animesList.add(id);
            }else if(status == 'plan_to_watch'){
              planning.animesList.add(id);
            }else if(status == 'completed'){
              completed.animesList.add(id);
            }else if(status == 'on_hold'){
              onHold.animesList.add(id);
            }else if(status == 'dropped'){
              dropped.animesList.add(id);
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
    List<UserAnimeListStatusClass> lists = [
      watching, planning, completed, onHold, dropped
    ];
    return Scaffold(
      appBar: AppBar(
        leading: defaultLeadingWidget(context),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Anime List'), titleSpacing: defaultAppBarTitleSpacing,
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
                    Tab(text: 'Watching'),
                    Tab(text: 'Planning'),
                    Tab(text: 'Completed'),
                    Tab(text: 'On Hold'),
                    Tab(text: 'Dropped')
                  ],                           
                )
              ),
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
                      fetchUserAnimesList(lists[x]);
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
                              CustomUserListAnimeDisplay(
                                animeData: AnimeDataClass.fetchNewInstance(-1),
                                displayType: AnimeRowDisplayType.myUserList,
                                skeletonMode: true,
                                key: UniqueKey()
                              )
                            );
                          }
                        ))
                      :
                        SliverList(delegate: SliverChildBuilderDelegate(
                          childCount: lists[x].animesList.length, 
                          (c, i) {
                            return ValueListenableBuilder(
                              valueListenable: appStateClass.globalAnimeData[lists[x].animesList[i]]!.notifier, 
                              builder: (context, animeData, child){
                                return CustomUserListAnimeDisplay(
                                  animeData: animeData,
                                  displayType: AnimeRowDisplayType.myUserList,
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