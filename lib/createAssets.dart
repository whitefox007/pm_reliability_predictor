import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '/assetViewModel.dart';
import '/inputWidget.dart';
// import 'package:image_picker_web/image_picker_web.dart';

enum PhotoOptions { camera, library }

class CreateAsset extends StatefulWidget {
  static String id = 'CreateAsset';
  const CreateAsset({Key? key}) : super(key: key);

  @override
  State<CreateAsset> createState() => _CreateAssetState();
}

class _CreateAssetState extends State<CreateAsset> {
  // final ImagePickerWeb _picker = ImagePickerWeb();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTextController = TextEditingController();

  bool active = false;

  final AssetViewModel newAsset = AssetViewModel();

  XFile? _image;
  void _selectPhotoFromPhotoLibrary() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
  }

  void _selectPhotoFromCamera() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = pickedFile;
    });
  }

  void _optionSelected(PhotoOptions option) {
    switch (option) {
      case PhotoOptions.camera:
        _selectPhotoFromCamera();
        break;
      case PhotoOptions.library:
        _selectPhotoFromPhotoLibrary();
        break;
    }
  }

  String? newValue = '1234';

  // Future<void> getMultipleImageInfos() async {
  //   var mediaData = await ImagePickerWeb.getImageInfo;
  //   // String? mimeType = mime(Path.basename(mediaData.fileName!));
  //   // html.File mediaFile =
  //   //     new html.File(mediaData.data!, mediaData.fileName!, {'type': mimeType});

  //   setState(() {
  //     // _cloudFile = mediaFile;
  //     _fileBytes = mediaData.data;
  //     _imageWidget = Image.memory(mediaData.data!);
  //   });
  // }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LoadingOverlay(
        isLoading: isLoading,
        child: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    inputText(
                        hint: 'Asset name',
                        label: 'Asset name',
                        validate: true,
                        controller: _nameTextController),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cover Image', style: TextStyle()),
                        const SizedBox(
                          height: 10,
                        ),
                        PopupMenuButton(
                          onSelected: _optionSelected,
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: PhotoOptions.camera,
                              child: Text("Take a picture"),
                            ),
                            const PopupMenuItem(
                              value: PhotoOptions.library,
                              child: Text("Select from photo library"),
                            )
                          ],
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 1),
                              image: _image == null
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(_image!.path))),
                            ),
                            child: _image == null
                                ? const Center(
                                    child: Text("Add Image"),
                                  )
                                : Container(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(children: [
                      const Text('Active',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        width: 20,
                      ),
                      Wrap(
                        spacing: 10.0,
                        children: [
                          // 4
                          ChoiceChip(
                            // 5
                            selectedColor: Colors.black,
                            // 6
                            selected: active == false,
                            label: const Text(
                              'Off',
                              style: TextStyle(color: Colors.white),
                            ),
                            // 7
                            onSelected: (selected) {
                              setState(() => active = false);
                            },
                          ),
                          const SizedBox(width: 20),
                          ChoiceChip(
                            selectedColor: Colors.red,

                            selected: active == true,
                            label: const Text(
                              'ON',
                              style: TextStyle(color: Colors.white),
                            ),
                            // 7
                            onSelected: (selected) {
                              setState(() => active = true);
                            },
                          )
                        ],
                      ),
                    ]),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: const Color(0xFF6FE9AF),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  DateTime dateTime = DateTime.now();
                                  String img =
                                      await newAsset.addImageForAndriod(_image);
                                  // ignore: use_build_context_synchronously
                                  newAsset.createAsset(
                                      name: _nameTextController.text,
                                      active: active,
                                      image: img,
                                      created: dateTime,
                                      createdby: 'James Sandy',
                                      context: context);
                                }
                                // Navigator.pushNamed(context, );
                                 setState(() {
                                    isLoading = false;
                                  });
                              },
                              child: const Text('Add',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900))),
                        ),
                        Expanded(flex: 1, child: Container()),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
