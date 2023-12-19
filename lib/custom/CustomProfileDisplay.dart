// ignore_for_file: use_build_context_synchronously
import 'package:anime_list_app/ViewUserAnimeLists.dart';
import 'package:anime_list_app/ViewUserMangaLists.dart';
import 'package:anime_list_app/ViewUserStatistics.dart';
import 'package:anime_list_app/appdata/GlobalLibrary.dart';
import 'package:anime_list_app/class/UserDataClass.dart';
import 'package:anime_list_app/class/UserTokenClass.dart';
import 'package:anime_list_app/custom/CustomButton.dart';
import 'package:anime_list_app/extensions/StringEllipsis.dart';
import 'package:anime_list_app/main.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/AppStyles.dart';
import 'package:anime_list_app/transition/RightToLeftTransition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomProfileDisplay extends StatefulWidget {
  final UserDataClass userData;
  final bool skeletonMode;

  const CustomProfileDisplay({
    super.key,
    required this.userData,
    required this.skeletonMode
  });

  @override
  State<CustomProfileDisplay> createState() => CustomProfileDisplayState();
}

class CustomProfileDisplayState extends State<CustomProfileDisplay>{
  late UserDataClass userData;
  
  @override void initState(){
    super.initState();
    userData = widget.userData;
  }

  void askLogOut(){
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Alert', textAlign: TextAlign.center),
          titlePadding: EdgeInsets.only(top: getScreenHeight() * 0.025),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to log out?', style: TextStyle(
                fontSize: defaultTextFontSize * 0.95
              )),
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomButton(
                    width: getScreenWidth() * 0.25, height: getScreenHeight() * 0.06, 
                    buttonColor: Colors.redAccent, buttonText: 'Yes', 
                    onTapped: (){
                      appStateClass.userTokenData = UserTokenClass(
                        '', '', '', ''
                      );
                      appStateClass.appStorage.updateUserToken();
                      runDelay(() => Navigator.pushAndRemoveUntil(
                        context,
                        SliderRightToLeftRoute(
                          page: const MyHomePage()
                        ),
                        (Route<dynamic> route) => false
                      ), navigatorDelayTime);
                    }, 
                    setBorderRadius: true
                  ),
                  CustomButton(
                    width: getScreenWidth() * 0.25, height: getScreenHeight() * 0.06, 
                    buttonColor: Colors.deepOrangeAccent, buttonText: 'No', 
                    onTapped: (){
                      Navigator.of(dialogContext).pop();
                    }, 
                    setBorderRadius: true
                  )
                ]
              )
            ]
          )
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if(!widget.skeletonMode){
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding,
          ),
          child: ListView(
            children: [
              SizedBox(
                height: defaultVerticalPadding * 2
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: getScreenWidth() * 0.2,
                    height:  getScreenWidth() * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      image: userData.profilePic != null ? 
                        DecorationImage(image: NetworkImage(userData.profilePic!), fit: BoxFit.fill)
                        : 
                        const DecorationImage(image: AssetImage("assets/images/default-user-picture.jpg"), fit: BoxFit.fill)
                    ),
                  ),
                  SizedBox(
                    width: getScreenWidth() * 0.04
                  ),
                  Text(
                    StringEllipsis.convertToEllipsis(userData.username), 
                    style: TextStyle(
                      fontSize: defaultTextFontSize * 1.15,
                      fontWeight: FontWeight.w500
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                  )
                ],
              ),
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(FontAwesomeIcons.venusMars, size: 17.5)
                    ),
                    Text(
                      userData.gender ?? 'Unspecified',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500
                      )
                    )
                  ]
                ),
              ),
              SizedBox(
                height: getScreenHeight() * 0.01
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(Icons.person_pin_circle_outlined, size: 25),
                    ),
                    Text(
                      userData.location != null ? userData.location!.isNotEmpty ? userData.location! : 'Unspecified' : 'Unspecified',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500
                      )
                    )
                  ]
                )
              ),
              SizedBox(
                height: getScreenHeight() * 0.01
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(Icons.cake, size: 20),
                    ),
                    Text(
                      userData.birthday != null ? convertDateTimeDisplay(userData.birthday!) : 'Unspecified',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500
                      )
                    )
                  ]
                ),
              ),
              SizedBox(
                height: getScreenHeight() * 0.01
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: getScreenHeight() * 0.00175
                        ),
                        child: const Icon(Icons.person_add, size: 22.5)
                      ),
                    ),
                    Text(
                      convertDateTimeDisplay(userData.joinedTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500
                      )
                    )
                  ]
                )
              ),
              SizedBox(height: getScreenHeight() * 0.025),
              CustomButton(
                width: getScreenWidth() * 0.6, height: getScreenHeight() * 0.07, 
                buttonColor: Colors.deepOrangeAccent, buttonText: 'Statistics', 
                onTapped: (){
                  runDelay(() => Navigator.push(
                    context,
                    SliderRightToLeftRoute(
                      page: const ViewUserStatistics()
                    )
                  ), navigatorDelayTime);
                }, 
                setBorderRadius: true
              ),
              SizedBox(height: getScreenHeight() * 0.02),
              CustomButton(
                width: getScreenWidth() * 0.6, height: getScreenHeight() * 0.07, 
                buttonColor: Colors.deepOrangeAccent, buttonText: 'Anime list', 
                onTapped: (){
                  runDelay(() => Navigator.push(
                    context,
                    SliderRightToLeftRoute(
                      page: const ViewUserAnimesList()
                    )
                  ), navigatorDelayTime);
                }, 
                setBorderRadius: true
              ),
              SizedBox(height: getScreenHeight() * 0.02),
              CustomButton(
                width: getScreenWidth() * 0.6, height: getScreenHeight() * 0.07, 
                buttonColor: Colors.deepOrangeAccent, buttonText: 'Manga list', 
                onTapped: (){
                  runDelay(() => Navigator.push(
                    context,
                    SliderRightToLeftRoute(
                      page: const ViewUserMangaLists()
                    )
                  ), navigatorDelayTime);
                }, 
                setBorderRadius: true
              ),
              SizedBox(height: getScreenHeight() * 0.02),
              CustomButton(
                width: getScreenWidth() * 0.6, height: getScreenHeight() * 0.07, 
                buttonColor: Colors.redAccent, buttonText: 'Log out', 
                onTapped: () => askLogOut(), 
                setBorderRadius: true
              ),
              SizedBox(
                height: defaultVerticalPadding * 2
              ),
            ],
          ),
        ),
      );
    }else{
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding,
          ),
          child: ListView(
            children: [
              SizedBox(
                height: defaultVerticalPadding * 2
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: getScreenWidth() * 0.1,
                    backgroundImage: AssetImage(iconImageUrl),
                  ),
                  SizedBox(
                    width: getScreenWidth() * 0.02
                  ),
                  Card(
                    child: Container(
                      color: Colors.grey,
                      width: getScreenWidth() * 0.7,
                      height:  getScreenWidth() * 0.1,
                    )
                  ),
                ],
              ),
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(FontAwesomeIcons.venusMars, size: 17.5)
                    ),
                  ]
                ),
              ),
              SizedBox(
                height: getScreenHeight() * 0.01
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(Icons.person_pin_circle_outlined, size: 25),
                    ),
                  ]
                )
              ),
              SizedBox(
                height: getScreenHeight() * 0.01
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(Icons.cake, size: 20),
                    ),
                  ]
                ),
              ),
              SizedBox(
                height: getScreenHeight() * 0.01
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.475),
                  borderRadius: const BorderRadius.all(Radius.circular(12.5))
                ),
                height: getScreenHeight() * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: getScreenHeight() * 0.00175
                        ),
                        child: const Icon(Icons.person_add, size: 22.5)
                      ),
                    ),
                  ]
                )
              ),
              SizedBox(height: getScreenHeight() * 0.0125),
              CustomButton(
                width: getScreenWidth() * 0.6, 
                height: getScreenHeight() * 0.07, 
                buttonColor: Colors.grey,
                buttonText: '',
                onTapped: (){},
                setBorderRadius: true
              ),
              SizedBox(height: getScreenHeight() * 0.01),
              CustomButton(
                width: getScreenWidth() * 0.6, 
                height: getScreenHeight() * 0.07, 
                buttonColor: Colors.grey,
                buttonText: '',
                onTapped: (){},
                setBorderRadius: true
              ),
              SizedBox(height: getScreenHeight() * 0.01),
              CustomButton(
                width: getScreenWidth() * 0.6, 
                height: getScreenHeight() * 0.07, 
                buttonColor: Colors.grey,
                buttonText: '',
                onTapped: (){},
                setBorderRadius: true
              ),
              SizedBox(height: getScreenHeight() * 0.01),
              CustomButton(
                width: getScreenWidth() * 0.6, 
                height: getScreenHeight() * 0.07, 
                buttonColor: Colors.grey,
                buttonText: '',
                onTapped: (){},
                setBorderRadius: true
              ),
              SizedBox(
                height: defaultVerticalPadding * 2
              ),
            ],
          ),
        ),
      );
    }
  }

}