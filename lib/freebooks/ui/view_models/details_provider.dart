import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/app_properties.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/download_helper.dart';
import '../../data/favorite_helper.dart';
import '../../data/freebooks_api.dart';
import '../../domain/models/category_feed.dart';
import '../../domain/models/freebook.dart';
import '../widgets/download_alert.dart';

class FreebooksDetailsProvider extends ChangeNotifier {
  CategoryFeed related = CategoryFeed();
  bool isLoading = true;
  Freebook? entry;
  var favDB = FavoriteDB();
  var dlDB = DownloadsDB();

  bool faved = false;
  bool downloaded = false;
  FreebooksAPI api = FreebooksAPI();
  bool isDownloadable = false;

  void getBooksFeed(String url) async {
    setLoading(true);
    checkFav();
    checkDownload();
    try {
      CategoryFeed feed = await api.getCategory(url);
      setRelated(feed);
      setLoading(false);
    } catch (e) {
      AppConfig.logger.e(e.toString());
    }
  }

  // check if book is favorited
  void checkFav() async {
    List c = await favDB.check({'id': entry!.id!});
    if (c.isNotEmpty) {
      setFaved(true);
    } else {
      setFaved(false);
    }
  }

  void addFav() async {
    await favDB.add({'id': entry!.id, 'item': entry!.toJson()});
    checkFav();
  }

  void removeFav() async {
    favDB.remove({'id': entry!.id!}).then((v) {
      AppConfig.logger.d(v);
      checkFav();
    });
  }

  // check if book has been downloaded before
  void checkDownload() async {
    List downloads = await dlDB.check({'id': entry!.id!});
    if (downloads.isNotEmpty) {
      // check if book has been deleted
      String path = downloads[0]['path'];
      AppConfig.logger.d(path);
      if (await File(path).exists()) {
        setDownloaded(true);
      } else {
        setDownloaded(false);
      }
    } else {
      setDownloaded(false);
    }
  }

  Future<List> getDownload() async {
    List c = await dlDB.check({'id': entry!.id!});
    return c;
  }

  Future<void> addDownload(Map body) async {
    await dlDB.removeAllWithId({'id': entry!.id!});
    await dlDB.add(body);
    checkDownload();
  }

  Future<void> removeDownload() async {
    dlDB.remove({'id': entry!.id!}).then((v) {
      AppConfig.logger.d(v);
      checkDownload();
    });
  }

  Future downloadFile(BuildContext context, String url, String filename) async {
    AppConfig.logger.d(url);
    PermissionStatus permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      // access media location needed for android 10/Q
      await Permission.accessMediaLocation.request();
      // manage external storage needed for android 11/R
      await Permission.manageExternalStorage.request();
      startDownload(context, url, filename);
    } else {
      startDownload(context, url, filename);
    }
  }

  Future<void> startDownload(BuildContext context, String url, String filename) async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      Directory('${appDocDir!.path.split('Android')[0]}${AppProperties.getAppName()}')
          .createSync();
    }

    String path = Platform.isIOS
        ? '${appDocDir!.path}/$filename.epub'
        : '${appDocDir!.path.split('Android')[0]}${AppProperties.getAppName()}/$filename.epub';
    AppConfig.logger.d(path);
    File file = File(path);
    if (!await file.exists()) {
      await file.create();
    } else {
      await file.delete();
      await file.create();
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DownloadAlert(
        url: url,
        path: path,
      ),
    ).then((v) {
      // When the download finishes, we then add the book
      // to our local database
      if (v != null) {
        addDownload(
          {
            'id': entry!.id!,
            'path': path,
            'image': '${entry!.link![1].href}',
            'size': v,
            'name': entry!.title!,
          },
        );
      }
    });
  }

  void setLoading(value) {
    isLoading = value;
    notifyListeners();
  }

  void setRelated(value) {
    related = value;
    notifyListeners();
  }

  CategoryFeed getRelated() {
    return related;
  }

  void setEntry(value) {
    entry = value;
    notifyListeners();
  }

  void setFaved(value) {
    faved = value;
    notifyListeners();
  }

  void setDownloaded(value) {
    downloaded = value;
    notifyListeners();
  }
}
