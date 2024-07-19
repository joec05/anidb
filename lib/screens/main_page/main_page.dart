import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainPageStateful();
  }
}

class _MainPageStateful extends StatefulWidget {
  const _MainPageStateful();

  @override
  State<_MainPageStateful> createState() => __MainPageStatefulState();
}

class __MainPageStatefulState extends State<_MainPageStateful>{
  ValueNotifier<int> selectedIndexValue = ValueNotifier(0);
  final PageController _pageController = PageController(initialPage: 0, keepPage: true);

  @override void initState(){
    super.initState();
  }

  @override void dispose(){
    super.dispose();
    selectedIndexValue.dispose();
    _pageController.dispose();
  }

  void onPageChanged(newIndex){
    if(mounted){
      selectedIndexValue.value = newIndex;
    }
  }

  final List<Widget> widgetOptions = <Widget>[
    const HomePage(), const ViewUserAnimeLists(), const ViewUserMangaLists()
  ];

  final List<String> appBarDisplayTexts = [
    'Home', 'Anime List', 'Manga List'
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexValue,
      builder: (BuildContext context, int selectedIndexValue, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: defaultAppBarDecoration
            ),
            title: Text(appBarDisplayTexts[selectedIndexValue]), 
            titleSpacing: defaultHomeAppBarTitleSpacing,
          ),
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: onPageChanged,
            children: widgetOptions,
          ),
          bottomNavigationBar: ClipRRect(                                                   
            child: SalomonBottomBar(
              //backgroundColor: Color.fromARGB(255, 35, 36, 33)
              backgroundColor: Colors.green.withOpacity(0.1),
              unselectedItemColor: const Color.fromARGB(255, 72, 77, 71),
              itemPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              key: UniqueKey(),
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(FontAwesomeIcons.house, size: 21),
                  title: const Text('Home'),
                  selectedColor: Colors.orange
                ),
                SalomonBottomBarItem(
                  icon: const Icon(FontAwesomeIcons.film, size: 21),
                  title: const Text('Anime List'),
                  selectedColor: Colors.orange
                ),
                SalomonBottomBarItem(
                  icon: const Icon(FontAwesomeIcons.book, size: 21),
                  title: const Text('Manga List'),
                  selectedColor: Colors.orange
                ),
              ],
              currentIndex: selectedIndexValue,
              onTap: ((index) {
                _pageController.jumpToPage(index);
              })
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: getScreenHeight() * 0.2,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                    ),
                    child: InkWell(
                      splashFactory: InkSplash.splashFactory,
                      onTap: () {
                        context.push('/profile-page');
                        router.pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: getScreenWidth() * 0.15,
                              height: getScreenWidth() * 0.15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: profileRepository.userData?.profilePic != null ? 
                                  DecorationImage(image: NetworkImage(profileRepository.userData!.profilePic!), fit: BoxFit.fill)
                                : 
                                  const DecorationImage(image: AssetImage("assets/images/unknown-item.png"), fit: BoxFit.fill)
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(profileRepository.userData?.username ?? '', style: const TextStyle(
                              fontSize: 17.5,
                              fontWeight: FontWeight.bold
                            ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 16.5
                  ),
                  title: const Text('Search', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    context.push('/search-page');
                    router.pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.film,
                    size: 18
                  ),
                  title: const Text('Anime Ranking', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    context.push('/view-anime-ranking');
                    router.pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.book,
                    size: 18
                  ),
                  title: const Text('Manga Ranking', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    context.push('/view-manga-ranking');
                    router.pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.gear,
                    size: 18
                  ),
                  title: const Text('Settings', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    context.push('/settings-page');
                    router.pop();
                  },
                ),
              ],
            ),
          )
        );
      }
    );
  }
}
