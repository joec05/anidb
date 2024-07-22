import 'package:anidb/global_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SearchPageStateful();
  }
}

class _SearchPageStateful extends StatefulWidget {
  const _SearchPageStateful();

  @override
  State<_SearchPageStateful> createState() => __SearchPageStatefulState();
}

class __SearchPageStatefulState extends State<_SearchPageStateful> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  TextEditingController searchController = TextEditingController();
  ValueNotifier<String> searchedText = ValueNotifier('');
  late TabController _tabController;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override void dispose(){
    super.dispose();
    searchController.dispose();
    searchedText.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarWidget(),
        title: TextField(
          controller: searchController,
          maxLines: 1,
          maxLength: 30,
          onEditingComplete: () {
            if(searchController.text.length < 4){
              handler.displaySnackbar(
                SnackbarType.error,
                tErr.searchTextMin
              );
            }else{
              searchedText.value = searchController.text;
            }
          },
          decoration: InputDecoration(
            counterText: "",
            contentPadding: EdgeInsets.symmetric(horizontal: getScreenWidth() * 0.025),
            fillColor: Colors.transparent,
            filled: true,
            hintText: 'Search anything',
            prefixIcon: Icon(
              FontAwesomeIcons.magnifyingGlass, 
              size: 16.5,
              color: Theme.of(context).iconTheme.color,
            ),
            constraints: BoxConstraints(
              maxWidth: getScreenWidth() * 0.75,
              maxHeight: getScreenHeight() * 0.07,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.grey),
              borderRadius: BorderRadius.circular(12.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.grey),
              borderRadius: BorderRadius.circular(12.5),
            ),
          )
        ),
        titleSpacing: getScreenWidth() * 0.025,
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
                    Tab(text: 'Anime'),
                    Tab(text: 'Manga'),
                    Tab(text: 'Characters')
                  ],
                )                           
            ),
            )
          ];
        },
        body: ValueListenableBuilder(
          valueListenable: searchedText,
          builder: (context, text, child){
            return TabBarView(
              controller: _tabController,
              children: [
                SearchedAnimesWidget(
                  searchedText: text,
                  absorberContext: context,
                  key: UniqueKey()
                ),
                SearchedMangasWidget(
                  searchedText: text,
                  absorberContext: context,
                  key: UniqueKey()
                ),
                SearchedCharactersWidget(
                  searchedText: text,
                  absorberContext: context,
                  key: UniqueKey()
                ),
              ]
            );
          }
        )
      )
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
