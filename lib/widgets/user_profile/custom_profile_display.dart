import 'package:anidb/global_files.dart';
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
  
  @override
  Widget build(BuildContext context) {
    if(!widget.skeletonMode){
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: defaultHorizontalPadding,
          ),
          child: Column(
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
                        const DecorationImage(image: AssetImage("assets/images/unknown-item.png"), fit: BoxFit.fill)
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
              SizedBox(
                height: getScreenHeight() * 0.05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(FontAwesomeIcons.venusMars, size: 14)
                    ),
                    Text(
                      userData.gender ?? '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                      )
                    )
                  ]
                ),
              ),
              SizedBox(
                height: getScreenHeight() * 0.05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(Icons.person_pin_circle_outlined, size: 21),
                    ),
                    Text(
                      userData.location != null ? userData.location!.isNotEmpty ? userData.location! : '?' : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                      )
                    )
                  ]
                )
              ),
              SizedBox(
                height: getScreenHeight() * 0.05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: getScreenWidth() * 0.15,
                      child: const Icon(Icons.cake, size: 17),
                    ),
                    Text(
                      userData.birthday != null ? convertDateTimeDisplay(userData.birthday!) : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                      )
                    )
                  ]
                ),
              ),
              SizedBox(
                height: getScreenHeight() * 0.05,
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
                        child: const Icon(Icons.person_add, size: 18)
                      ),
                    ),
                    Text(
                      convertDateTimeDisplay(userData.joinedTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                      )
                    )
                  ]
                )
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
          child: Column(
            children: [
              SizedBox(
                height: defaultVerticalPadding * 2
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: getScreenWidth() * 0.1,
                    backgroundImage: const AssetImage('assets/images/icon.png'),
                  ),
                  SizedBox(
                    width: getScreenWidth() * 0.02
                  ),
                  Card(
                    child: Container(
                      color: Colors.grey,
                      width: getScreenWidth() * 0.65,
                      height:  getScreenWidth() * 0.1,
                    )
                  ),
                ],
              ),
              SizedBox(
                height: getScreenHeight() * 0.025
              ),
              SizedBox(
                height: getScreenHeight() * 0.05,
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
                height: getScreenHeight() * 0.05,
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
                height: getScreenHeight() * 0.05,
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
                height: getScreenHeight() * 0.05,
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