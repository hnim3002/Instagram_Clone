
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:provider/provider.dart';


import '../../providers/user_provider.dart';
import '../../resources/firestore_method.dart';



class CropUserImgScreen extends StatefulWidget {
  final Uint8List file;
  const CropUserImgScreen({super.key, required this.file});

  @override
  State<CropUserImgScreen> createState() => _CropUserImgScreenState();
}

class _CropUserImgScreenState extends State<CropUserImgScreen> {
  late CustomImageCropController controller;
  final double _cropPercentage = 1;
  final Ratio _radio = Ratio(width: 1, height: 1);


  @override
  void initState() {
    // TODO: implement initState
    controller = CustomImageCropController();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

  Future<void> postImage(
      String uid, Uint8List file) async {
    try {
      await FirestoreMethods().updateUserImg(uid, await compressImage(file, 80));

    } catch (e) {
      print(e);
    }
  }

  Future<void> _cropImage(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.0, // Set the desired width
                  height: 20.0, // Set the desired height
                  child: CircularProgressIndicator(strokeWidth: 3.0),
                ),
                SizedBox(width: 10,),
                Text('Processing...'), // Processing text
              ],
            ),
          ),

        );
      },
    );
    String uid = Provider.of<UserProvider>(context, listen: false).user!.uid!;
    final image = await controller.onCropImage();
    await postImage(uid, image!.bytes);
    await refreshUser();
    if (!context.mounted) return;

    Navigator.of(context).pop();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> refreshUser() async {
    await Provider.of<UserProvider>(context, listen: false).refreshUser();
  }

  void onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Crop image"),
          actions: [TextButton(
              onPressed: () {
                _cropImage(context);
              },
              child: const Text(
                "Next",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              )
          )],
          leading: IconButton(
            onPressed: () {
              onBackPressed();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: CustomImageCrop(
                    imageFit: CustomImageFit.fillCropSpace,
                    cropPercentage: _cropPercentage,
                    overlayColor: isDarkMode ? Colors.black : Colors.white,
                    pathPaint: Paint(),
                    forceInsideCropArea: true,
                    ratio: _radio,
                    canRotate: false,
                    borderRadius: 15,
                    shape: CustomCropShape.Circle,
                    cropController: controller,
                    image: MemoryImage(widget.file),
                    customProgressIndicator: const CircularProgressIndicator(),
                  ),
                ),
              ]
          ),
        ));
  }
}
