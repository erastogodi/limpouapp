import 'package:flutter/material.dart';
import 'package:limpou25k/utils/app_routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasNewNotification;

  const CustomAppBar({Key? key, this.hasNewNotification = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.amber.shade700,
      elevation: 0,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
            if (hasNewNotification)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
