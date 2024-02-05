
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/screens/post_screen/posting_screen.dart';
import 'package:material_symbols_icons/symbols.dart';


class CropImgScreen extends StatefulWidget {
  final Uint8List file;
  const CropImgScreen({super.key, required this.file});

  @override
  State<CropImgScreen> createState() => _CropImgScreenState();
}

class _CropImgScreenState extends State<CropImgScreen> {
  late CustomImageCropController controller;
  double _cropPercentage = 1;
  Ratio _radio = Ratio(width: 1, height: 1);


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

  void onPressedChangeRatio() {
    if(_cropPercentage == 1) {
      setState(() {
        _cropPercentage = 0.8;
        _radio = Ratio(width: 4, height: 5);
      });
    } else {
      setState(() {
        _cropPercentage = 1;
        _radio = Ratio(width: 1, height: 1);
      });
    }
  }

  Future<void> _cropImage(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 95),
          shape: RoundedRectangleBorder( // Custom shape
            borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
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
    final image = await controller.onCropImage();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostingScreen(file: image!.bytes)));
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
                  shape: CustomCropShape.Square,
                  cropController: controller,
                  image: MemoryImage(widget.file),
                  customProgressIndicator: const CircularProgressIndicator(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  onPressedChangeRatio();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F929B)
                ),
                child: const Text("Change ratio", style: TextStyle(color: Colors.white),)
              )
            ]
          ),
    ));
  }
}
