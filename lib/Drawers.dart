import 'package:flutter/material.dart';

import 'Adminlar.dart';
import 'Buyurtma_yaratish.dart';
import 'Harajatlar.dart';
import 'Servislar.dart';
import 'Settings.dart';
import 'Tayyor_buyurtma.dart';
import 'YangiBuyurtma.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/buyurtma-qabuli';

    Widget buildMenuItem({
      required IconData icon,
      required String title,
      required Widget page,
      required String routeName,
    }) {
      final bool isSelected = currentRoute == routeName;

      return ListTile(
        leading: Icon(icon, color: isSelected ? Colors.green : Colors.grey.shade700),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green.shade800 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? Colors.green.shade50 : null,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => page,
              settings: RouteSettings(name: routeName),
            ),
          );
        },
      );
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, left: 20, right: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              color: Color(0xFF215234),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, color: Color(0xFF215234)),
                ),
                SizedBox(width: 12),
                Text(
                  'Gilam Servis',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                const SizedBox(height: 10),
                buildMenuItem(
                  icon: Icons.add,
                  title: 'Buyurtma qabuli',
                  page:  YangiBuyurtmalarPage(),
                  routeName: '/buyurtma-qabuli',
                ),
                buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Adminlar',
                  page:  AdminScreen(),
                  routeName: '/adminlar',
                ),
                buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Servislar',
                  page: const ServiceListScreen(),
                  routeName: '/servislar',
                ),
                buildMenuItem(
                  icon: Icons.list_alt,
                  title: 'Yangi buyurtmalar',
                  page: const ClientListPage(),
                  routeName: '/yangi-buyurtmalar',
                ),
                buildMenuItem(
                  icon: Icons.access_time,
                  title: 'Tayyor buyurtmalar',
                  page: const ClientOrderCardPage(),
                  routeName: '/tayyor-buyurtmalar',
                ),
                buildMenuItem(
                  icon: Icons.paid_outlined,
                  title: 'Harajatlar',
                  page: const HarajatlarPage(),
                  routeName: '/harajatlar',
                ),
                buildMenuItem(
                  icon: Icons.settings,
                  title: 'Sozlamalar',
                  page:  SozlamalarPage(),
                  routeName: '/sozlamalar',
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Tizimdan chiqish',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                // Logout funksiyasini yozing
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Tizimdan chiqish'),
                    content: const Text('Rostdan ham tizimdan chiqmoqchimisiz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Bekor qilish'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Bu yerda logout logikasi yoziladi
                          print('Tizimdan chiqildi');
                        },
                        child: const Text('Chiqish'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}