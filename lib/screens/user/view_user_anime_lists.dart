import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewUserAnimeLists extends ConsumerWidget {
  const ViewUserAnimeLists({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ViewUserAnimeListsStateful();
  }
}

class _ViewUserAnimeListsStateful extends ConsumerStatefulWidget {
  const _ViewUserAnimeListsStateful();

  @override
  ConsumerState<_ViewUserAnimeListsStateful> createState() => _ViewUserAnimeListsStatefulState();
}

class _ViewUserAnimeListsStatefulState extends ConsumerState<_ViewUserAnimeListsStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late UserAnimeController controller;
  late TabController _tabController;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    controller = UserAnimeController();
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
    List<AsyncValue<UserAnimeListStatusClass>> watchProviders = List.generate(statusNotifiers.length, (i) => ref.watch(statusNotifiers[i]));

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
                    Tab(text: 'Watching'),
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
                              child: CustomUserListAnimeDisplay(
                                animeData: AnimeDataClass.fetchNewInstance(-1),
                                displayType: AnimeRowDisplayType.myUserList,
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
                              childCount: data.animeList.length, 
                              (c, i) {
                                return CustomUserListAnimeDisplay(
                                  animeData: data.animeList[i],
                                  displayType: AnimeRowDisplayType.myUserList,
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