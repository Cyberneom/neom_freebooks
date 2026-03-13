import 'package:flutter/material.dart';
import 'package:neom_commons/ui/widgets/images/handled_cached_network_image.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/freebook.dart';
import '../../freebooks_router.dart';
import '../books/details/epub_details.dart';

class BookItem extends StatelessWidget {
  final String img;
  final String title;
  final Freebook entry;

  BookItem({
    super.key,
    required this.img,
    required this.title,
    required this.entry,
  });

  static const uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NeomFreebooksRouter.pushPage(
          context,
          EPUBDetails(
            entry: entry,
            imgTag: imgTag,
            titleTag: titleTag,
            authorTag: authorTag,
          ),
        );
      },
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            child: Hero(
              tag: imgTag,
              child: HandledCachedNetworkImage(
                img,
                fit: BoxFit.cover,
                height: 150.0,
                enableFullScreen: false,
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Hero(
            tag: titleTag,
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                title.replaceAll(r'\', ''),
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
