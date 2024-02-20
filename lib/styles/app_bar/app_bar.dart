import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

BoxDecoration defaultAppBarDecoration = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 76, 153, 106), Color.fromARGB(255, 185, 82, 13)
    ],
    stops: [
      0.25, 0.6
    ],
  ),
);

Widget defaultLeadingWidget(BuildContext context){
  return InkWell(
    splashFactory: InkRipple.splashFactory,
    onTap: () => context.mounted ? runDelay(() => Navigator.pop(context), 0) : (){},
    child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white)
  );
}

double defaultAppBarTitleSpacing = getScreenWidth() * 0.02;

double defaultHomeAppBarTitleSpacing = getScreenWidth() * 0.06;