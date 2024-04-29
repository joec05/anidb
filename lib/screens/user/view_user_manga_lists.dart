import 'package:anime_list_app/global_files.dart';
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
  late UserMangaController controller;
  late TabController _tabController;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    controller = UserMangaController(context);
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
                  tabAlignment: TabAlignment.start,
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
        body: ListenableBuilder(
          listenable: Listenable.merge([
            controller.reading, 
            controller.planning, 
            controller.completed, 
            controller.onHold, 
            controller.dropped
          ]),
          builder: (context, child) {
            List<UserMangaListStatusClass> lists = [
              controller.reading.value, 
              controller.planning.value, 
              controller.completed.value, 
              controller.onHold.value, 
              controller.dropped.value
            ];

            List<ValueNotifier<UserMangaListStatusClass>> listenables = [
              controller.reading, 
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
                          controller.fetchUserMangasList(listenables[x]);
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
                                        CustomUserListMangaDisplay(
                                          mangaData: MangaDataClass.fetchNewInstance(-1),
                                          displayType: MangaRowDisplayType.myUserList,
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
                                  childCount: lists[x].mangasList.length, 
                                  (c, i) {
                                    return ValueListenableBuilder(
                                      valueListenable: appStateRepo.globalMangaData[lists[x].mangasList[i]]!.notifier, 
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