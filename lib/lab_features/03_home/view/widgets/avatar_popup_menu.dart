import 'package:flutter/material.dart';

enum StudentAction {
  profile,
  help,
  logout
}

class AvatarPopupMenu extends StatefulWidget {
  const AvatarPopupMenu({super.key});

  @override
  State<AvatarPopupMenu> createState() => _AvatarPopupMenuState();
}

class _AvatarPopupMenuState extends State<AvatarPopupMenu> with SingleTickerProviderStateMixin {
  StudentAction? selectedItem;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StudentAction>(
        constraints: BoxConstraints.tight(const Size(120, 160)),
        surfaceTintColor: Colors.white,
        iconColor: Colors.black,
        icon: Material(
          color: Colors.transparent,
          type: MaterialType.card,
          child: CircleAvatar(
              maxRadius: 15,
              backgroundColor: Colors.deepOrange[900],
              child: const Text(
                'J',
                style: TextStyle(fontSize: 18, color: Colors.white),
              )),
        ),
        onSelected: (StudentAction item) {
          setState(() {
            selectedItem = item;
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<StudentAction>>[
              PopupMenuItem<StudentAction>(
                  value: StudentAction.profile,
                  child: Text(
                    'Your profile',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.lightBlue[300]),
                  )),
              PopupMenuItem<StudentAction>(
                  value: StudentAction.help,
                  child: Text(
                    'Help & Support',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.lightBlue[300]),
                  )),
              PopupMenuItem<StudentAction>(
                  value: StudentAction.logout,
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.lightBlue[300]),
                  ))
            ]);
  }
}
