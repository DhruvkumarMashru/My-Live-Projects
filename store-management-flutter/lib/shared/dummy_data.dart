import '../local_db/inventory_db.dart';
import '../model/performance_model.dart';
import '../model/inventroy_model.dart'; // Typo in original file name handling it correctly here if needed, else we only use inventory_db

class DummyData {
  
  static List<Map<String, dynamic>> getSuppliers() {
    return [
      {'id': 1, 'name': 'TechTronix Supply', 'phone': '555-0100'},
      {'id': 2, 'name': 'Global Imports LLC', 'phone': '555-0101'},
      {'id': 3, 'name': 'Alpha Wholesale', 'phone': '555-0102'},
      {'id': 4, 'name': 'Mega Traders Co.', 'phone': '555-0103'},
      {'id': 5, 'name': 'NextGen Distributors', 'phone': '555-0104'},
      {'id': 6, 'name': 'Apex Retail Goods', 'phone': '555-0105'},
      {'id': 7, 'name': 'Prime Goods Inc', 'phone': '555-0106'},
      {'id': 8, 'name': 'Quantum Electronics', 'phone': '555-0107'},
      {'id': 9, 'name': 'Vertex Supply Chain', 'phone': '555-0108'},
      {'id': 10, 'name': 'Titan Delivery Corp', 'phone': '555-0109'},
    ];
  }

  static List<PerformanceModel> getSales() {
    return [
      PerformanceModel(id: 1, productName: 'Wireless Mouse', price: '25.00', soldQuantity: '14'),
      PerformanceModel(id: 2, productName: 'Mechanical Keyboard', price: '89.99', soldQuantity: '8'),
      PerformanceModel(id: 3, productName: 'USB-C Cable', price: '12.50', soldQuantity: '45'),
      PerformanceModel(id: 4, productName: 'Gaming Headset', price: '55.00', soldQuantity: '12'),
      PerformanceModel(id: 5, productName: '27-inch Monitor', price: '210.00', soldQuantity: '3'),
      PerformanceModel(id: 6, productName: 'Laptop Stand', price: '34.99', soldQuantity: '22'),
      PerformanceModel(id: 7, productName: 'Webcam 1080p', price: '45.00', soldQuantity: '6'),
      PerformanceModel(id: 8, productName: 'Bluetooth Speaker', price: '60.00', soldQuantity: '18'),
      PerformanceModel(id: 9, productName: 'Power Bank', price: '22.00', soldQuantity: '30'),
      PerformanceModel(id: 10, productName: 'Ergonomic Desk Chair', price: '150.00', soldQuantity: '5'),
    ];
  }

  static Map<String, dynamic> getDashboard() {
    return {
      'storeMovement': [
        {'date': 'Mon', 'views': '120'},
        {'date': 'Tue', 'views': '145'},
        {'date': 'Wed', 'views': '210'},
        {'date': 'Thu', 'views': '180'},
        {'date': 'Fri', 'views': '290'},
        {'date': 'Sat', 'views': '350'},
        {'date': 'Sun', 'views': '415'},
      ],
      'bestSelling': [
        {'item_name': 'USB-C Cable', 'sales': 45},
        {'item_name': 'Power Bank', 'sales': 30},
        {'item_name': 'Laptop Stand', 'sales': 22},
        {'item_name': 'Bluetooth Speaker', 'sales': 18},
      ],
      'leastSelling': [
        {'item_name': '27-inch Monitor', 'sales': 3},
        {'item_name': 'Ergonomic Desk Chair', 'sales': 5},
        {'item_name': 'Webcam 1080p', 'sales': 6},
        {'item_name': 'Mechanical Keyboard', 'sales': 8},
      ],
      'lowStock': [
        {'item_name': '27-inch Monitor', 'quantity': 2},
        {'item_name': 'Ergonomic Desk Chair', 'quantity': 4},
        {'item_name': 'Notebook Pack', 'quantity': 3},
        {'item_name': 'Novelty T-Shirt', 'quantity': 5},
      ]
    };
  }

  static Future<void> injectLocalInventoryIfEmpty() async {
    final existingProducts = await InventoryDb.getAllProducts();
    if (existingProducts.isEmpty) {
        // Insert 10 dummy items
        await _insertItem('1000000000001', 'Smartphone Pro', '150', '2027-01-01', '400', 'Electronics', '799.99');
        await _insertItem('1000000000002', 'Wireless Earbuds', '300', '2028-05-12', '50', 'Electronics', '129.50');
        await _insertItem('1000000000003', 'Coffee Mugs Set', '80', '2030-10-10', '10', 'Home Office', '25.00');
        await _insertItem('1000000000004', 'Leather Wallet', '200', '2035-12-31', '15', 'Accessories', '45.00');
        await _insertItem('1000000000005', 'Novelty T-Shirt', '500', '2040-01-01', '5', 'Apparel', '15.00');
        await _insertItem('1000000000006', 'Gaming Mouse', '120', '2026-06-15', '20', 'Electronics', '59.99');
        await _insertItem('1000000000007', 'Notebook Pack', '400', '2025-11-20', '3', 'Stationery', '12.99');
        await _insertItem('1000000000008', 'Water Bottle', '250', '2050-01-01', '8', 'Accessories', '22.00');
        await _insertItem('1000000000009', 'Running Shoes', '60', '2026-10-10', '40', 'Apparel', '110.00');
        await _insertItem('1000000000010', 'Desk Lamp', '45', '2031-02-14', '18', 'Home Office', '39.99');
    }
  }

  static Future<void> _insertItem(
      String barcode, String name, String qty, String exp, String cost, String category, String price) async {
      await InventoryDb.insertProduct(
        barcode: barcode,
        itemName: name,
        stockQuantity: qty,
        expirationDate: exp,
        cost: cost,
        category: category,
        price: price,
      );
  }
}
