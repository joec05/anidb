import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPageWidget extends StatelessWidget {
  const MainPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainPageWidgetStateful();
  }
}

class _MainPageWidgetStateful extends StatefulWidget {
  const _MainPageWidgetStateful();

  @override
  State<_MainPageWidgetStateful> createState() => __MainPageWidgetStatefulState();
}

class __MainPageWidgetStatefulState extends State<_MainPageWidgetStateful>{
  ValueNotifier<int> selectedIndexValue = ValueNotifier(0);
  final PageController _pageController = PageController(initialPage: 0, keepPage: true, );
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override void initState(){
    super.initState();
  }

  void resetBottomNavIndex(){
    _pageController.jumpToPage(0);
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
    const HomePage(), const ExplorePage(), const ProfilePage()
  ];

  PreferredSizeWidget setAppBar(index){
    if(index == 0){
      return AppBar(
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Home'), 
        titleSpacing: defaultHomeAppBarTitleSpacing,
      );
    }else if(index == 1){
      return AppBar(
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Explore'),
            GestureDetector(
              onTap: (){
                runDelay(() => Navigator.push(
                  context,
                  NavigationTransition(
                    page: const SearchPageWidget()
                  )
                ), navigatorDelayTime);
              },
              child: const Icon(FontAwesomeIcons.magnifyingGlass, size: 22.5)
            )
          ]
        ), 
        titleSpacing: defaultHomeAppBarTitleSpacing,
      );
    }else if(index == 2){
      return AppBar(
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Profile'), titleSpacing: defaultHomeAppBarTitleSpacing,
      );
    }
    return AppBar();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexValue,
      builder: (BuildContext context, int selectedIndexValue, Widget? child) {
        return Scaffold(
          key: scaffoldKey,
          drawerEdgeDragWidth: 0.85 * getScreenWidth(),
          onDrawerChanged: (isOpened) {
            if(isOpened){
            }
          },
          appBar: setAppBar(selectedIndexValue),
          body: PageView(
            controller: _pageController,
            onPageChanged: onPageChanged,
            children: widgetOptions,
          ),
          bottomNavigationBar:ClipRRect(                                                            
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15)
            ),                                                     
            child: BottomNavigationBar(
              fixedColor: Colors.red.withOpacity(0.75),
              unselectedItemColor: Colors.blueGrey,
              backgroundColor: const Color.fromARGB(255, 78, 75, 75),
              key: UniqueKey(),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.house, size: 25),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 25),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.user, size: 25),
                  label: 'Profile',
                ),
              ],
              currentIndex: selectedIndexValue,
              onTap: ((index) {
                _pageController.jumpToPage(index);
              })
            ),
          )
        );
      }
    );
  }
}
