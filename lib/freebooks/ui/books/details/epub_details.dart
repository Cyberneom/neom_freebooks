import 'package:cached_network_image/cached_network_image.dart';
// import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sint/sint.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/widgets/app_circular_progress_indicator.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/ui/widgets/right_side_company_logo.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/category.dart';
import '../../../domain/models/freebook.dart';
import '../../view_models/details_provider.dart';
import '../../widgets/book_list_item.dart';
import '../../widgets/description_text.dart';
import '../../widgets/loading_widget.dart';

class EPUBDetails extends StatefulWidget {
  final Freebook entry;
  final String imgTag;
  final String titleTag;
  final String authorTag;

  const EPUBDetails({
    super.key,
    required this.entry,
    required this.imgTag,
    required this.titleTag,
    required this.authorTag,
  });

  @override
  EPUBDetailsState createState() => EPUBDetailsState();
}

class EPUBDetailsState extends State<EPUBDetails> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (controller) {

        Provider.of<FreebooksDetailsProvider>(context, listen: false)
            .setEntry(widget.entry);
        Provider.of<FreebooksDetailsProvider>(context, listen: false)
            .getBooksFeed(widget.entry.author!.uri!.replaceAll(r'\&lang=en', ''));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FreebooksDetailsProvider>(
      builder: (BuildContext context, FreebooksDetailsProvider provider,
          Widget? child) {
        return Scaffold(
          backgroundColor: AppColor.main75,
          appBar: AppBarChild(
            actionWidgets: const [
              RightSideCompanyLogo()
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: <Widget>[
              const SizedBox(height: 10.0),
              _buildImageTitleSection(provider),
              const SizedBox(height: 30.0),
              _buildSectionTitle('Descripción del libro'),
              _buildDivider(),
              const SizedBox(height: 10.0),
              DescriptionTextWidget(
                text: widget.entry.summary ?? '',
              ),
              const SizedBox(height: 30.0),
              _buildSectionTitle('Más del autor'),
              _buildDivider(),
              const SizedBox(height: 10.0),
              _buildMoreBook(provider),
            ],
          ),
        );
      },
    );
  }

  Divider _buildDivider() {
    return Divider(
      color: Theme.of(context).textTheme.bodySmall!.color,
    );
  }

  Row _buildImageTitleSection(FreebooksDetailsProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Hero(
          tag: widget.imgTag,
          child: CachedNetworkImage(
            imageUrl: '${widget.entry.link![1].href}',
            placeholder: (context, url) => const SizedBox(
              height: 200.0,
              width: 130.0,
              child: LoadingWidget(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
            fit: BoxFit.cover,
            height: 200.0,
            width: 130.0,
          ),
        ),
        const SizedBox(width: 20.0),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5.0),
              Hero(
                tag: widget.titleTag,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    widget.entry.title!.replaceAll(r'\', ''),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Hero(
                tag: widget.authorTag,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(widget.entry.author!.name ?? '',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              _buildCategory(widget.entry, context),
              Center(
                child: SizedBox(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  //TODO ADD LOGIC TO DOWNLOAD PDFS AND EPUBS FOR OFFLINE READ
                  child: !provider.isDownloadable ? _buildReadOnlineButton(provider, context) : _buildDownloadReadButton(provider, context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Text _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMoreBook(FreebooksDetailsProvider provider) {
    if (provider.isLoading) {
      return const AppCircularProgressIndicator();
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.related.feed!.entry!.length,
        itemBuilder: (BuildContext context, int index) {
          Freebook entry = provider.related.feed!.entry![index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: BookListItem(
              entry: entry,
            ),
          );
        },
      );
    }
  }

  Future<void> openBook(FreebooksDetailsProvider provider) async {
    //TODO
    // List dlList = await provider.getDownload();
    // if (dlList.isNotEmpty) {
    //   // dlList is a list of the downloads relating to this Book's id.
    //   // The list will only contain one item since we can only
    //   // download a book once. Then we use `dlList[0]` to choose the
    //   // first value from the string as out local book path
    //   Map dl = dlList[0];
    //   String path = dl['path'];
    //
    //   // MyRouter.pushPage(context, EpubScreen.fromPath(filePath: path));
    // }
  }

  TextButton _buildReadOnlineButton(FreebooksDetailsProvider provider, BuildContext context) {
    return TextButton(
        onPressed: () {
          Sint.toNamed(AppRouteConstants.epubViewer,
              arguments: [widget.entry, true,]
          );
        },
        child: const Text('Leer Libro',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ),
    );
  }

  TextButton _buildDownloadReadButton(FreebooksDetailsProvider provider, BuildContext context) {
    if (provider.downloaded) {
      return TextButton(
        onPressed: () => openBook(provider),
        child: const Text('Leer Libro',
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
      );
    } else {
      return TextButton(
        onPressed: () => provider.downloadFile(
          context,
          widget.entry.link![3].href!,
          widget.entry.title!.replaceAll(' ', '_').replaceAll(r"\'", "'"),
        ),
        child: const Text('Descargar',
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
      );
    }
  }

  Widget _buildCategory(Freebook entry, BuildContext context) {
    if (entry.category == null) {
      return const SizedBox();
    } else {
      return SizedBox(
        height: entry.category!.length < 3 ? 55.0 : 95.0,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entry.category!.length > 4 ? 4 : entry.category!.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 210 / 80,
          ),
          itemBuilder: (BuildContext context, int index) {
            Category cat = entry.category![index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.bondiBlue75,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      '${cat.label}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: cat.label!.length > 18 ? 6.0 : 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

}
