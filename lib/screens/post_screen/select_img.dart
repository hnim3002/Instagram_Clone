import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'dart:io' show Platform;
import 'package:transparent_image/transparent_image.dart';

class PostScreen extends StatefulWidget {
  final Function closeBtnOnPressed;
  const PostScreen({super.key, required this.closeBtnOnPressed});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Medium? _medium;
  List<Medium>? _media;
  List<Album>? _albums;
  String albumsName = "Unnamed Album";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMedia();
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  void updateMedia(Album album) async {
    MediaPage mediaPage = await album.listMedia();
    setState(() {
      albumsName = album.name!;
      _media = mediaPage.items;
      _medium = mediaPage.items[0];
    });
  }

  void initMedia() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums();
      MediaPage mediaPage = await albums[0].listMedia();
      setState(() {
        albumsName = albums[0].name!;
        _media = mediaPage.items;
        _medium = mediaPage.items[0];
        _albums = albums;

      });
    }
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 40,
                  height: 5, // Height of the divider
                  margin: const EdgeInsets.symmetric(vertical: 10), // Adjust vertical spacing
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    color: Colors.grey[700], // Divider color
                  ),
                ),
                Stack(
                  alignment:Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 17
                          ),
                        )
                      ),
                    ),
                    const Text(
                      "Select album",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double gridWidth = (constraints.maxWidth - 20) / 3;
                      double gridHeight = gridWidth + 33;
                      double ratio = gridWidth / gridHeight;
                      return Container(
                        padding: const EdgeInsets.all(5),
                        child: GridView.count(
                          childAspectRatio: ratio,
                          crossAxisCount: 3,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                          children: <Widget>[
                            ...?_albums?.map(
                              (album) => GestureDetector(
                                onTap: () {
                                  updateMedia(album);
                                  Navigator.pop(context);
                                },
                                child: Column(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        color: Colors.grey[300],
                                        height: gridWidth,
                                        width: gridWidth,
                                        child: FadeInImage(
                                          fit: BoxFit.cover,
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          image: AlbumThumbnailProvider(
                                            album: album,
                                            highQuality: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Text(
                                        album.name ?? "Unnamed Album",
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          height: 1.2,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Text(
                                        album.count.toString(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          height: 1.2,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("New post"),
        actions: [TextButton(onPressed: () {}, child: const Text("Next"))],
        leading: IconButton(
          onPressed: () {
            widget.closeBtnOnPressed();
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                  height: 370,
                  width: double.infinity,
                  child: _medium == null
                      ? const CircularProgressIndicator()
                      : ClipRect(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: _medium?.mediumType == MediumType.image
                                ? FadeInImage(
                                    placeholder: MemoryImage(kTransparentImage),
                                    image: PhotoProvider(
                                      mediumId: _medium!.id,
                                    ),
                                  )
                                : Container(),
                          ),
                        )),
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextButton(
                        onPressed: () {
                          showBottomSheet();
                        },
                        child: Row(
                          children: [
                            Text(
                              albumsName,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            const Icon(
                              Icons.expand_more,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt))
                  ],
                ),
              ),
              Expanded(
                child: _medium == null
                    ? const CircularProgressIndicator()
                    : GridView.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 1.0,
                        crossAxisSpacing: 1.0,
                        children: <Widget>[
                          ...?_media?.map(
                            (medium) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _medium = medium;
                                });
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  FadeInImage(
                                    fit: BoxFit.cover,
                                    placeholder: MemoryImage(kTransparentImage),
                                    image: ThumbnailProvider(
                                      mediumId: medium.id,
                                      mediumType: medium.mediumType,
                                      highQuality: true,
                                    ),
                                  ),
                                  Container(
                                    color: _medium == medium
                                        ? Colors.white60
                                        : Colors.transparent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              )
        ],
      )),
    );
  }
}