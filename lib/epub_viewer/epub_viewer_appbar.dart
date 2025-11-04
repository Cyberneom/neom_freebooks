import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';

class EPUBViewerAppBar extends StatelessWidget implements PreferredSizeWidget {

  final String title;
  final bool goBack;
  final Color? color;

  const EPUBViewerAppBar({this.title = "", this.color, this.goBack = false, super.key});

  @override
  Size get preferredSize => AppTheme.appBarHeight;

  @override
  Widget build(BuildContext context) {


    return AppBar(
      title: Text(title.capitalize, style: TextStyle(color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.bold),
      ),
      backgroundColor: color ?? AppColor.appBar,
      elevation: 0.0,
      actions: [
        TextButton(
          child: Text(AppTranslationConstants.goBack.tr,
            style: const TextStyle(fontSize: 15,
                color: AppColor.lightGrey,
                decoration: TextDecoration.underline
            ),
          ),
          onPressed: ()=> Navigator.pop(context)
        ),
      ],
    );
  }

}
