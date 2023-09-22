import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProfileAvatarWidget extends StatelessWidget {
  String? profileImagePath;
  int? profileColor;
  double size;
  ProfileAvatarWidget(
      {super.key, required this.profileColor, required this.profileImagePath, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage:
          profileImagePath != null && profileImagePath != "" ? NetworkImage(profileImagePath!) : null,
      backgroundColor: Color(profileColor ?? 0xFFFFE082),
      radius: size,
      child: profileImagePath == null || profileImagePath == ""
          ? const Icon(
            Icons.person,
            size: 30,
          )
          : null,
    );
  }
}
