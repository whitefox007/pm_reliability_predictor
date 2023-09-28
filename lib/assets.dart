import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '/assetDetail.dart';
import '/controller/asset_controller.dart';
import '/controller/firebaseGet.dart';
import '/createAssets.dart';
import '/responsiveness.dart';

class Assets extends StatefulWidget {
  const Assets({Key? key}) : super(key: key);

  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends State<Assets> {
  FirebaseGet firebaseGet = Get.put(FirebaseGet());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
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
                    return Expanded(
                      child: ListView.builder(
                          itemCount: assets.assets.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: Card(
                                elevation: 3,
                                child: Slidable(
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
                                                                  primary: Colors
                                                                      .green),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              'Cancel')),
                                                      ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  primary:
                                                                      Colors.red),
                                                          onPressed: () {
                                                            FirebaseGet()
                                                                .deleteAsset(
                                                                    assets
                                                                        .assets[
                                                                            index]
                                                                        .id!);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('Yes'))
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
                                  child: buildListTile(assets, index, context),
                                ),
                              ),
                            );
                          }),
                    );
                  }),
              ResponsiveWidget.isSmallScreen(context)
                  ? Expanded(
                      child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 20,
                              bottom: 20,
                            ),
                            child: FloatingActionButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const CreateAsset();
                                }));
                              },
                              child: const Icon(Icons.add),
                            ),
                          )),
                    )
                  : Container()
            ],
          ),
        
      ),
    );
  }

  ListTile buildListTile(
      AssetController assets, int index, BuildContext context) {
    return ListTile(
      title: Text('${assets.assets[index].name}'),
      onTap: () {
        firebaseGet.assetid.value = assets.assets[index].id!;

        showDialog(
            context: context,
            builder: (context) {
              return AssetDetail(
                assetName: assets.assets[index].name,
                assetid: assets.assets[index].id,
                imageUrl: assets.assets[index].image,
              );
            });
      },
    );
  }
}
