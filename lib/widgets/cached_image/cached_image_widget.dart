import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImageWidget extends StatelessWidget {

  final dynamic imageClass;
  final dynamic width;
  final dynamic height;

  const CachedImageWidget({
    super.key, 
    required this.imageClass,
    this.width,
    this.height
  });

  @override
  Widget build(BuildContext context) {
    if(imageClass == null){
      return Image.asset(
        'assets/images/unknown-item.png',
        fit: BoxFit.cover
      );
    }

    return CachedNetworkImage(
      imageUrl: imageClass.large, 
      width: width,
      height: height,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, error, stackTrace) => SizedBox(
        width: width,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator()
            ),
          ],
        ),
      ),
      errorWidget: (context, error, stackTrace) => Image.asset(
        'assets/images/unknown-item.png',
        fit: BoxFit.cover
      ),
      fadeInDuration: const Duration(milliseconds: 250)
    );
  }
}