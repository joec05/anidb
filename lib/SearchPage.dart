import 'package:anime_list_app/SearchedAnimes.dart';
import 'package:anime_list_app/SearchedMangas.dart';
import 'package:anime_list_app/SearchedCharacters.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/custom/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'styles/AppStyles.dart';

class SearchPageWidget extends StatelessWidget {
  const SearchPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SearchPageWidgetStateful();
  }
}

class _SearchPageWidgetStateful extends StatefulWidget {
  const _SearchPageWidgetStateful();

  @override
  State<_SearchPageWidgetStateful> createState() => __SearchPageWidgetStatefulState();
}

class __SearchPageWidgetStatefulState extends State<_SearchPageWidgetStateful> with SingleTickerProviderStateMixin{
  TextEditingController searchController = TextEditingController();
  ValueNotifier<String> searchedText = ValueNotifier('');
  ValueNotifier<bool> verifySearchedFormat = ValueNotifier(false);
  late TabController _tabController;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    searchController.addListener((){
      verifySearchedFormat.value = searchController.text.isNotEmpty;
    });
  }

  @override void dispose(){
    super.dispose();
    searchController.dispose();
    searchedText.dispose();
    verifySearchedFormat.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: defaultLeadingWidget(context),
        title: ValueListenableBuilder(
          valueListenable: verifySearchedFormat,
          builder: (context, allowPress, child){
            return TextField(
              controller: searchController,
              maxLines: 1,
              maxLength: 30,
              decoration: InputDecoration(
                counterText: "",
                contentPadding: EdgeInsets.symmetric(horizontal: getScreenWidth() * 0.025),
                fillColor: Colors.transparent,
                filled: true,
                hintText: 'Search anything',
                suffixIcon: TextButton(
                  onPressed: (){
                    if(searchController.text.length < 4){
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Alert', textAlign: TextAlign.center,),
                            titlePadding: EdgeInsets.only(top: getScreenHeight() * 0.025),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Minimum 4 characters needed!!!', style: TextStyle(fontSize: defaultTextFontSize)),
                                SizedBox(
                                  height: getScreenHeight() * 0.02,
                                ),
                                CustomButton(
                                  width: getScreenWidth() * 0.5, 
                                  height: getScreenHeight() * 0.06, 
                                  buttonColor: Colors.orange, 
                                  buttonText: 'OK', 
                                  onTapped: () => Navigator.of(dialogContext).pop(), 
                                  setBorderRadius: true
                                )
                              ]
                            )
                          );
                        }
                      );
                    }else{
                      searchedText.value = searchController.text;
                    }
                  },
                  child: Icon(
                    FontAwesomeIcons.magnifyingGlass, 
                    size: 20, 
                    color: allowPress ? Colors.blue : Colors.white.withOpacity(0.65)
                  )
                ),
                constraints: BoxConstraints(
                  maxWidth: getScreenWidth() * 0.75,
                  maxHeight: getScreenHeight() * 0.07,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.75), width: 2),
                  borderRadius: BorderRadius.circular(12.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.75), width: 2),
                  borderRadius: BorderRadius.circular(12.5),
                ),
              )
            );
          }
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
}
