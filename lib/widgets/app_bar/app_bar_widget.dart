import 'package:anime_list_app/constants/delay/functions.dart';
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {

  const AppBarWidget({
    super.key, 
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: InkRipple.splashFactory,
      onTap: () => context.mounted ? runDelay(() => Navigator.pop(context), 0) : (){},
      child: const Icon(Icons.arrow_back_ios_new, size: 20)
    );
  }
}