import 'package:anime_list_app/global_files.dart';
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
  late UserAnimeController controller;
  late TabController _tabController;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    controller = UserAnimeController(context);
    controller.initializeController();
  }

  @override void dispose(){
    super.dispose();
    _tabController.dispose();
    controller.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
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
        body: ListenableBuilder(
          listenable: Listenable.merge([
            controller.watching, 
            controller.planning, 
            controller.completed, 
            controller.onHold, 
            controller.dropped
          ]),
          builder: (context, child) {
            List<UserAnimeListStatusClass> lists = [
              controller.watching.value, 
              controller.planning.value, 
              controller.completed.value, 
              controller.onHold.value, 
              controller.dropped.value
            ];

            List<ValueNotifier<UserAnimeListStatusClass>> listenables = [
              controller.watching, 
              controller.planning, 
              controller.completed, 
              controller.onHold, 
              controller.dropped
            ];

            return TabBarView(
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
                          controller.fetchUserAnimesList(listenables[x]);
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
                          ValueListenableBuilder(
                            valueListenable: controller.isLoading,
                            builder: (context, isLoadingValue, child) {
                              if(isLoadingValue == true) {
                                return SliverList(
                                  delegate: SliverChildBuilderDelegate(
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
                                  )
                                );
                              }
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: lists[x].animesList.length, 
                                  (c, i) {
                                    return ValueListenableBuilder(
                                      valueListenable: appStateRepo.globalAnimeData[lists[x].animesList[i]]!.notifier, 
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
                                )
                              );
                            }
                          )
                        ]
                      )
                    );
                  }
                )
              ]
            );
          }
        )
      )
    );
  }
}