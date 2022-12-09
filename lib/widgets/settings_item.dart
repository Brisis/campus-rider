import 'dart:math';

import 'package:campus_rider/helpers/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final String? trailing;
  final IconData icon;

  const SettingsItem({
    Key? key,
    required this.onTap,
    required this.title,
    this.trailing,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      dense: true,
      minLeadingWidth: 20,
      onTap: onTap,
      leading: icon == CupertinoIcons.reply
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: Icon(
                icon,
                size: 20,
                color: kTextGrey,
              ),
            )
          : Icon(
              icon,
              size: 20,
              color: kTextGrey,
            ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing!,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
