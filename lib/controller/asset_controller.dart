import 'package:get/get.dart';
import '/controller/firebaseGet.dart';

import '../assetModel.dart';

class AssetController extends GetxController {
  final assets = <AssetModel>[].obs;

  @override
  void onInit() {
    assets.bindStream(FirebaseGet().getAssets());
    super.onInit();
  }
}
