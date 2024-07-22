import 'package:anidb/global_files.dart';
import 'package:flutter/material.dart';

/// Returns the content of a snackbar in widget form. Typically contains text and sometimes an icon as well.
Widget snackbarContentTemplate(IconData? iconData, String text) => Row(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    iconData != null ? Icon(iconData, size: 17) : Container(),
    SizedBox(
      width: iconData != null ? getScreenWidth() * 0.035 : 0
    ),
    Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, textAlign: TextAlign.left, style: const TextStyle(
            fontWeight: FontWeight.bold
          ))
        ],
      ),
    )
  ],
);