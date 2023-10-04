import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '/assetDetail.dart';
import '/controller/asset_controller.dart';
import '/controller/firebaseGet.dart';
import '/createAssets.dart';
import '/responsiveness.dart';
import 'assetModel.dart';

class Assets extends StatefulWidget {
  const Assets({Key? key}) : super(key: key);

  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends State<Assets> {
  FirebaseGet firebaseGet = Get.put(FirebaseGet());
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 30,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(width: 0.8),
                              ),
                              hintText: 'Search',
                              suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.clear))),
                        ),
                      ),
                    ),
                    !ResponsiveWidget.isSmallScreen(context)
                        ? Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateAsset()));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add_circle),
                                      Text('New Asset'),
                                    ],
                                  ),
                                )),
                          )
                        : Container(),
                    const SizedBox(
                      width: 30,
                    )
                  ],
                ),
              ),
              GetX<AssetController>(
                  init: Get.put<AssetController>(AssetController()),
                  builder: (AssetController assets) {
                    final filteredAssets = assets.assets.where((asset) {
                      final assetName = asset.name?.toLowerCase() ?? '';
                      final query = searchQuery.toLowerCase();
                      return assetName.contains(query);
                    }).toList();
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: filteredAssets.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: ((context) async {
                                    await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return AlertDialog(
                                              content: const Text(
                                                  'All data about this asset will be lost. Are You Sure You want to Delete'),
                                              actions: [
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary:
                                                                Colors.green),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary:
                                                                Colors.red),
                                                    onPressed: () {
                                                      FirebaseGet().deleteAsset(
                                                          filteredAssets[index]
                                                              .id!);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Yes'))
                                              ],
                                            );
                                          });
                                        });
                                    setState(() {});
                                  }),
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: buildListTile(filteredAssets, index, context),
                          );
                        });
                  }),
            ],
          ),
        ),
        floatingActionButton: ResponsiveWidget.isSmallScreen(context)
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const CreateAsset();
                  }));
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Padding buildListTile(
      List<AssetModel> assets, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 10),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onTap: () {
            firebaseGet.assetid.value = assets[index].id!;

            showDialog(
                context: context,
                builder: (context) {
                  return AssetDetail(
                    assetName: assets[index].name,
                    assetid: assets[index].id,
                    imageUrl: assets[index].image,
                  );
                });
          },
          child: Container(
            width: 350,
            height: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: assets[index].image == "" ||
                        assets[index].image == null
                    ? const DecorationImage(
                        image:
                            AssetImage("assets/images/Image_not_available.png"),
                        fit: BoxFit.cover)
                    : DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            assets[index].image!))),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    assets[index].name!,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
