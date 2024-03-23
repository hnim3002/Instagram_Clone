import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../Widgets/custom_button_widgets.dart';
import '../../utils/color_schemes.dart';

class ImgPickerMessaging extends StatefulWidget {
  final ScrollController scrollController;
  final String chatRoomId;
  const ImgPickerMessaging(
      {super.key, required this.scrollController, required this.chatRoomId});

  @override
  State<ImgPickerMessaging> createState() => _ImgPickerMessagingState();
}

class _ImgPickerMessagingState extends State<ImgPickerMessaging> {
  late Future<List<Medium>?> _media;
  File? _file;
  Medium? _medium;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _media = initMedia();
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

  // void updateMedia(Album album) async {
  //   MediaPage mediaPage = await album.listMedia();
  //   setState(() {
  //     _media = mediaPage.items;
  //     _medium = mediaPage.items[0];
  //   });
  //   setFile();
  // }

  Future<List<Medium>?> initMedia() async {
    List<Medium>? media;
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums();
      MediaPage mediaPage = await albums[0].listMedia();
      media = mediaPage.items;
    }
    return media;
  }

  Future<void> setFile() async {
    _file = await PhotoGallery.getFile(
      mediumId: _medium!.id,
      mediumType: _medium!.mediumType,
      mimeType: _medium!.mimeType,
    );
  }

  void onItemSelect(Medium medium) {
    _medium = medium;
    setFile();
  }

  Future<void> sendImage(dynamic file) async {
    await FirestoreMethods().uploadChatMessageImg(
        uid: FirebaseAuth.instance.currentUser!.uid,
        file: await compressImage(await convertToUint8List(file), 80),
        chatRoomId: widget.chatRoomId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<Uint8List> convertToUint8List(img) async {
    return await img.readAsBytes();
  }

  Future<Uint8List> compressImage(Uint8List imageBytes, int quality) async {
    try {
      final compressedImageBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality, // Compression quality (0 to 100)
      );
      return compressedImageBytes;
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            margin: const EdgeInsets.symmetric(
                vertical: 10), // Adjust vertical spacing
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Rounded corners
              color: Colors.grey[700], // Divider color
            ),
          ),
          const Center(
            child: Text(
              "Select Photo",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: FutureBuilder(
                future: _media,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                            "No media found. Please allow access to your photos."));
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          GridView.count(
                            controller: widget.scrollController,
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            mainAxisSpacing: 5.0,
                            crossAxisSpacing: 5.0,
                            children: <Widget>[
                              ...?snapshot.data?.map(
                                (medium) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      onItemSelect(medium);
                                    });
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      FadeInImage(
                                        fit: BoxFit.cover,
                                        placeholder:
                                            MemoryImage(kTransparentImage),
                                        image: ThumbnailProvider(
                                          mediumId: medium.id,
                                          mediumType: medium.mediumType,
                                          highQuality: true,
                                        ),
                                      ),
                                      Positioned(
                                        top: 5, // Adjust as needed
                                        left: 5, // Adjust as needed
                                        child: Container(
                                          width: 25, // Adjust as needed
                                          height: 25, // Adjust as needed
                                          decoration: BoxDecoration(
                                            color: _medium == medium
                                                ? blueBtnColor
                                                : Colors.white60,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                              color: Colors
                                                  .white, // Set border color
                                              width: 2, // Set border width
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: _medium != null ? 1 : 0,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                              width: constraints.maxWidth,
                              height: 45,
                              child: CustomButton(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  sendImage(_file);
                                },
                                buttonContext: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ))
                                    : const Text(
                                        'Send',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
