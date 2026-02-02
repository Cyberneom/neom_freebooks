import 'package:flutter/material.dart';
import 'package:sint/sint.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';

import '../epub_viewer/epub_viewer_page.dart';

class NeomFreebooksRouter {
  static Future pushPage(BuildContext context, Widget page) {
    var val = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );

    return val;
  }

  static Future pushPageDialog(BuildContext context, Widget page) {
    var val = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
        fullscreenDialog: true,
      ),
    );

    return val;
  }

  static void pushPageReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

}

class NeomFreebooksRoutes {

  static final List<SintPage<dynamic>> routes = [
    SintPage(
        name: AppRouteConstants.epubViewer,
        page: () => const EPUBViewerPage(),
        transition: Transition.zoom
    ),
  ];

}
