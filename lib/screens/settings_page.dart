import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>{

  void askLogOut(){
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
                    buttonColor: Colors.red, buttonText: 'Yes', 
                    onTapped: (){
                      authRepo.userTokenData = UserTokenClass(
                        '', '', '', ''
                      );
                      secureStorageController.updateUserToken();
                      while(context.canPop()) {
                        context.pop();
                      }
                      context.push('/');
                    }, 
                    setBorderRadius: true
                  ),
                  CustomButton(
                    width: getScreenWidth() * 0.25, height: getScreenHeight() * 0.06, 
                    buttonColor: Colors.blueGrey, 
                    buttonText: 'No', 
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

  Widget settingWidget(Widget leading, String title, Function() onTap, {subtitle}) {
    return ListTile(
      leading: leading,
      title: Text(title, style: const TextStyle(fontSize: 15.5)),
      subtitle: subtitle == null ? null : Text(subtitle, style: const TextStyle(fontSize: 12.5)),
      onTap: onTap
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings')
      ),
      body: ListView(
        children: [
          settingWidget(
            Image.asset('assets/images/icon.png', width: 30, height: 30),
            'Version',
            () {},
            subtitle: '1.0.0',
          ),
          ValueListenableBuilder(
            valueListenable: themeModel.mode,
            builder: (context, mode, child) => settingWidget(
              SizedBox(width: 30, child: Icon(mode == ThemeMode.dark ? FontAwesomeIcons.sun : FontAwesomeIcons.moon, size: 18.5)),
              'Theme',
              () => runDelay(() {
                themeModel.toggleMode();
                context.pushReplacement('/settings-page');
              }, navigatorDelayTime)
            )
          ),
          settingWidget(
            const SizedBox(width: 30, child: Icon(FontAwesomeIcons.userLock, size: 16.5)),
            'Privacy Policy',
            () async => await launchUrl(
              Uri.parse('https://joec05.github.io/privacy-policy.github.io/anidb/main.html'), 
              mode: LaunchMode.externalApplication
            )
          ),
          settingWidget(
            const SizedBox(width: 30, child: Icon(FontAwesomeIcons.github, size: 21.5)),
            'Github',
            () async => await launchUrl(
              Uri.parse('https://github.com/joec05/anidb'), 
              mode: LaunchMode.externalApplication
            )
          ),
          settingWidget(
            const SizedBox(width: 30, child: Icon(FontAwesomeIcons.arrowRightFromBracket, size: 20)),
            'Log Out',
            askLogOut,
          )
        ]
      ),
    );
  }

}