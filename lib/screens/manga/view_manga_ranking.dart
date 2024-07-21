import 'package:anime_list_app/controllers/manga/manga_ranking_controller.dart';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewMangaRanking extends ConsumerWidget {

  const ViewMangaRanking({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ViewMangaRankingStateful();
  }
}

class _ViewMangaRankingStateful extends ConsumerStatefulWidget {

  const _ViewMangaRankingStateful();

  @override
  ConsumerState<_ViewMangaRankingStateful> createState() => _ViewMangaRankingStatefulState();
}

class _ViewMangaRankingStatefulState extends ConsumerState<_ViewMangaRankingStateful> with SingleTickerProviderStateMixin {
  late MangaRankingController controller;
  late TabController _tabController;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller = MangaRankingController();
    controller.initialize();
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
        title: const Text('Manga Ranking'), titleSpacing: defaultAppBarTitleSpacing,
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
                              return CustomUserListMangaDisplay(
                                mangaData: data.dataList[i],
                                displayType: MangaRowDisplayType.ranking,
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