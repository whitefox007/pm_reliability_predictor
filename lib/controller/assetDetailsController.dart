import 'package:get/get.dart';
import '/controller/firebaseGet.dart';

import '../assetDataModel.dart';

class AssetDetailController extends GetxController {
  final assetDetails = <AssetDataModel>[].obs;
  final assetsState = <bool?>[].obs;

  @override
  void onInit() {
    assetDetails.bindStream(FirebaseGet().getAssetDetails());
    assetsState.bindStream(FirebaseGet().getAssetsState());

    super.onInit();
  }
}
