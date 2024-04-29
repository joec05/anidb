import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

BoxDecoration defaultAppBarDecoration = const BoxDecoration(
  color: Colors.transparent
);

Widget defaultLeadingWidget(BuildContext context){
  return InkWell(
    splashFactory: InkRipple.splashFactory,
    onTap: () => context.mounted ? runDelay(() => Navigator.pop(context), 0) : (){},
    child: const Icon(Icons.arrow_back_ios_new, size: 20)
  );
}

double defaultAppBarTitleSpacing = getScreenWidth() * 0.02;

double defaultHomeAppBarTitleSpacing = getScreenWidth() * 0.06;