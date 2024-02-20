import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget generateCachedImage(dynamic imageClass){
  if(imageClass == null){
    return Image.asset(
      'assets/images/unknown-item.png',
      fit: BoxFit.cover
    );
  }

  return CachedNetworkImage(
    imageUrl: imageClass.large, 
    fit: BoxFit.cover,
    errorWidget: (context, error, stackTrace) => Image.asset(
      'assets/images/unknown-item.png',
      fit: BoxFit.cover
    ),
    fadeInDuration: const Duration(milliseconds: 250)
  );
}