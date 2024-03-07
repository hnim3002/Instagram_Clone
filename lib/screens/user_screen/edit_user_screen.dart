import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/screens/user_screen/edit_data_screen.dart';
import 'package:instagram_clon/utils/color_schemes.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart' as model;
import '../../providers/user_provider.dart';
import '../select_img.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).user;
    _controller = TextEditingController(text: user!.fullname);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit profile",
          style: TextStyle(
              letterSpacing: 0.5, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl!),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>const PostScreen(isUserScreen: true,)));
                  },
                  child: const Text("Edit picture or avatar",
                      style: TextStyle(color: blueBtnColor)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomDisplayUserData(
                label: "Name",
                text: user.fullname!,
                onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditUserData(label: "Name", text: user.fullname!))),
              ),
              CustomDisplayUserData(
                label: "Username",
                text: user.username!,
                onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditUserData(
                            label: "Username", text: user.username!))),
              ),
              CustomDisplayUserData(
                label: "Bio",
                text: user.bio!,
                onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditUserData(label: "Bio", text: user.bio!))),
              ),
              CustomDisplayUserData(
                label: "Email",
                text: user.email!,
                onPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditUserData(label: "Email", text: user.email!))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDisplayUserData extends StatelessWidget {
  final String label;
  final String text;
  final Function onPress;
  const CustomDisplayUserData({
    super.key,
    required this.label,
    required this.text,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3), // Adjust spacing as needed
        GestureDetector(
          onTap: () {
            onPress();
          },
          child: Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 16.5),
          ),
        ),
        Divider(
          color: Colors.grey.shade300,
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
