import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewUserMangaLists extends ConsumerWidget {
  const ViewUserMangaLists({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ViewUserMangaListsStateful();
  }
}

class _ViewUserMangaListsStateful extends ConsumerStatefulWidget {
  const _ViewUserMangaListsStateful();

  @override
  ConsumerState<_ViewUserMangaListsStateful> createState() => _ViewUserMangaListsStatefulState();
}

class _ViewUserMangaListsStatefulState extends ConsumerState<_ViewUserMangaListsStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late UserMangaController controller;
  late TabController _tabController;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    controller = UserMangaController();
    controller.initialize();
  }

  @override void dispose(){
    super.dispose();
    _tabController.dispose();
    controller.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final statusNotifiers = controller.statusNotifiers;
    List<AsyncValue<UserMangaListStatusClass>> watchProviders = List.generate(statusNotifiers.length, (i) => ref.watch(statusNotifiers[i]));
    return Scaffold(
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
                    Tab(text: 'Dropped'),
                    Tab(text: 'On Hold')
                  ],                           
                )
              ),
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            for(int x = 0; x < watchProviders.length; x++)
            watchProviders[x].when(
              loading: () => Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: skeletonLoadingDefaultLimit, 
                          (c, i) {
                            return ShimmerWidget(
                              child: CustomUserListMangaDisplay(
                                mangaData: MangaDataClass.fetchNewInstance(-1),
                                displayType: MangaRowDisplayType.myUserList,
                                skeletonMode: true,
                                key: UniqueKey()
                              )
                            );
                          }
                        )
                      ),
                    ],
                  );
                }
              ),
              error: (obj, stackTrace) => Builder(
                builder: (context) {
                  return  CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false, 
                        child: DisplayErrorWidget(displayText: obj.toString())
                      ),
                    ],
                  );
                }
              ),
              data: (data) {
                return Builder(
                  builder: (context) {
                    return LoadMoreBottom(
                      addBottomSpace: data.canPaginate,
                      loadMore: () async{
                        if(data.canPaginate){
                          context.read(statusNotifiers[x].notifier).paginate();
                        }
                      },
                      status: data.paginationStatus,
                      refresh: () => context.read(controller.statusNotifiers[x].notifier).refresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverOverlapInjector(
                            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: data.mangaList.length, 
                              (c, i) {
                                return CustomUserListMangaDisplay(
                                  mangaData: data.mangaList[i],
                                  displayType: MangaRowDisplayType.myUserList,
                                  skeletonMode: false,
                                  key: UniqueKey()
                                );
                              }
                            )
                          )
                        ]
                      )
                    );
                  }
                );
              }
            )
          ]
        )
      )
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}