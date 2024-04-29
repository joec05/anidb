import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
        automaticallyImplyLeading: false
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
            Row(
              children: [
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                  onTap: () => context.push('/search-page'),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(FontAwesomeIcons.magnifyingGlass, size: 17.5),
                  ),
                ),
                SizedBox(
                  width: getScreenWidth() * 0.05
                ),
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                  onTap: () => context.push('/settings-page'),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(FontAwesomeIcons.gear, size: 17.5),
                  ),
                ),
              ],
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
        automaticallyImplyLeading: false
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
          appBar: setAppBar(selectedIndexValue),
          body: PageView(
            controller: _pageController,
            onPageChanged: onPageChanged,
            children: widgetOptions,
          ),
          bottomNavigationBar: ClipRRect(                                                   
            child: BottomNavigationBar(
              fixedColor: const Color.fromARGB(255, 153, 108, 54),
              backgroundColor: const Color.fromARGB(255, 71, 75, 53),
              unselectedItemColor: const Color.fromARGB(255, 165, 161, 149),
              key: UniqueKey(),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.house, size: 20),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.user, size: 20),
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
