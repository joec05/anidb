import 'package:anidb_app/controllers/anime/anime_ranking_controller.dart';
import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewAnimeRanking extends ConsumerWidget {

  const ViewAnimeRanking({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ViewAnimeRankingStateful();
  }
}

class _ViewAnimeRankingStateful extends ConsumerStatefulWidget {

  const _ViewAnimeRankingStateful();

  @override
  ConsumerState<_ViewAnimeRankingStateful> createState() => _ViewAnimeRankingStatefulState();
}

class _ViewAnimeRankingStatefulState extends ConsumerState<_ViewAnimeRankingStateful> with SingleTickerProviderStateMixin {
  final AnimeRankingController controller = AnimeRankingController();
  late TabController _tabController;

  @override void initState() {
    controller.initialize();
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarWidget(),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Anime Ranking'), titleSpacing: defaultAppBarTitleSpacing,
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
                  isScrollable: false,
                  controller: _tabController,
                  labelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Score'),
                    Tab(text: 'Popularity'),
                    Tab(text: 'Favourite')
                  ],                           
                )
              ),
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            for(int x = 0; x < controller.notifiers.length; x++)
            ref.watch(controller.notifiers[x]).when(
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
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverOverlapInjector(
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: data.dataList.length, 
                            (c, i) {
                              return CustomUserListAnimeDisplay(
                                animeData: data.dataList[i],
                                displayType: AnimeRowDisplayType.ranking,
                                skeletonMode: false,
                                key: UniqueKey()
                              );
                            }
                          )
                        )
                      ]
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
}