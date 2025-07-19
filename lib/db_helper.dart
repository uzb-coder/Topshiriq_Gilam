import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> _getDatabase() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'buyurtmalar.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            surname TEXT,
            phone TEXT,
            address TEXT,
            description TEXT,
            mainService TEXT,
            mainQuantity TEXT,
            deliveryDate TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE added_services (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId INTEGER,
            service TEXT,
            quantity TEXT,
            FOREIGN KEY(orderId) REFERENCES orders(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _db!;
  }

  /// 🟢 Buyurtmani qo‘shish
  static Future<int> insertOrder(Map<String, dynamic> orderData) async {
    final db = await _getDatabase();
    return await db.insert('orders', orderData);
  }

  /// 🟢 Qo‘shimcha xizmatlarni qo‘shish
  static Future<void> insertAddedServices(
      int orderId, List<Map<String, dynamic>> services) async {
    final db = await _getDatabase();
    for (var service in services) {
      await db.insert('added_services', {
        'orderId': orderId,
        'service': service['service'],
        'quantity': service['quantity'],
      });
    }
  }
}
