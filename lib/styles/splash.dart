import 'package:flutter/material.dart';

Widget splashTileWidget({Widget? title, Widget? subtitle, Widget? leading, Function()? onTap}) {
  return InkWell(
    splashFactory: InkSplash.splashFactory,
    hoverDuration: Duration.zero,
    onTap: () {
      Future.delayed(const Duration(milliseconds: 250), () {
        if(onTap != null) {
          onTap();
        }
      });
    },
    child: ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      enabled: true,
    ),
  );
}

Widget splashWidget({Widget? child, Function()? onTap, bool? circularBorder}) {
  return InkWell(
    customBorder: circularBorder == true ? const CircleBorder() : null,
    splashFactory: InkSplash.splashFactory,
    hoverDuration: Duration.zero,
    onTap: () {
      Future.delayed(const Duration(milliseconds: 250), () {
        if(onTap != null) {
          onTap();
        }
      });
    },
    child: child
  );
}