import 'package:store_management_modern/model/inventroy_model.dart';
import '../local_db/inventory_db.dart';

class PurchasesRepo {
  static List<InventoryModel> listOfInventoryModel = [];

  static Future<List<InventoryModel>> getProductList(
      {required String apiPath,
      required String nameAtapi,
      required String? itemName}) async {
    listOfInventoryModel.clear();
    try {
      if (itemName == null || itemName.isEmpty) {
        listOfInventoryModel = await InventoryDb.getAllProducts();
      } else {
        listOfInventoryModel =
            await InventoryDb.searchByField(field: nameAtapi, value: itemName);
      }
      return listOfInventoryModel;
    } catch (e) {
      return listOfInventoryModel;
    }
  }
}
