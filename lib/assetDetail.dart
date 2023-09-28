import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/assetDataModel.dart';
import '/assetDataViewModel.dart';
import 'dart:math';

class AssetDetail extends StatefulWidget {
  const AssetDetail({Key? key, this.assetName, this.assetid, required this.imageUrl}) : super(key: key);

  final String? assetName;
  final String? imageUrl;
  final String? assetid;

  @override
  State<AssetDetail> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AssetDetail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hourTextController = TextEditingController();
  bool _giveVerse = true;
  String _selectedValue = 'Normal';
  List<String> listOfValue = ['Normal', 'Fault'];
  String fault = '';
  int hours = 0;
  bool validation = true;
  String validationMessage = 'Please Enter Asset Fault';
  final AssetDataViewModel addAssetDetail = AssetDataViewModel();
  DateTime calcMaxDate(List dates) {
    DateTime maxDate = dates[0];
    for (var date in dates) {
      if (date.isAfter(maxDate)) {
        maxDate = date;
      }
    }
    return maxDate;
  }

  Future<String?> _getAssetID() async {
    var companyUser = await FirebaseFirestore.instance
        .collection('assets')
        .doc()
        .collection('assetsData')
        .where('active', isEqualTo: false)
        .get();
    var newlist = companyUser.docs.map((docs) {
      return AssetDataModel.fromDocument(docs).id;
    }).toList();
    if (newlist.isEmpty) {
      return null;
    } else {
      return newlist[0];
    }
  }

  double predictResult = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // title: const Text('Reliability Predictor'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: TabBar(
                  indicatorColor: Colors.red,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.red),
                    color: Colors.red,
                  ),
                  unselectedLabelColor: Colors.red,
                  tabs: const [
                    Text('Details'),
                    Text('Predictor'),
                    Text('Log'),
                  ]),
            ),
            Expanded(
              child: TabBarView(children: [
                details(context, widget.assetid),
                predictor(context, widget.assetid!),
                workOrders(context, widget.assetid!),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Column workOrders(BuildContext context, String assetid) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Center(
              child: Text(
            '${widget.assetName} Log',
            style: Theme.of(context).textTheme.headlineMedium,
          )),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('assets')
                .doc(assetid)
                .collection('assetsData')
                .where('assetid', isEqualTo: widget.assetid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('loading.......');
              }
              if (snapshot.hasError) {
                return const Text('No Data Available');
              }
              final assetDetails = snapshot.data!.docs.map((docs) {
                return AssetDataModel.fromDocument(docs);
              }).toList();
              assetDetails.sort((a, b) => b.shutDown!.compareTo(a.shutDown!));

              List<DataColumn> getColumns(List<String> columns) => columns
                  .map((String column) => DataColumn(
                        label: Text(column),
                      ))
                  .toList();

              List<String> assetDataCol = [
                'Fault',
                'Statue',
                'Shut DOwn',
                'Turn ON ',
              ];

              List<DataCell> getCells(List<dynamic> cells) =>
                  cells.map((cell) => DataCell(Text("$cell"))).toList();

              List<DataRow> getRows(List<AssetDataModel> assetDetails) =>
                  assetDetails.map((AssetDataModel assetData) {
                    String status = assetData.active! ? "Checked" : "Unchecked";
                    final cells = [
                      assetData.fault,
                      status,
                      assetData.shutDown,
                      assetData.turnOn
                    ];
                    return DataRow(cells: getCells(cells));
                  }).toList();
              return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: getColumns(assetDataCol),
                    rows: getRows(assetDetails),
                  ));
            })
      ],
    );
  }

  Column predictor(BuildContext context, String assetid) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Center(
              child: Text(
            '${widget.assetName} Prediction',
            style: Theme.of(context).textTheme.headlineMedium,
          )),
        ),
        Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _hourTextController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Reliabiulity Hour(s)';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    hintText: 'Enter Prediction in Hours'),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF6FE9AF),
                      onPrimary: Colors.black,
                    ),
                    onPressed: () async {
                      Future<void> _getReliability(hoursValue) async {
                        var asset = await FirebaseFirestore.instance
                            .collection('assets')
                            .doc(assetid)
                            .collection('assetsData')
                            .where('assetid', isEqualTo: assetid)
                            .get();
                        var newlist = asset.docs.map((docs) {
                          return AssetDataModel.fromDocument(docs);
                        }).toList();

                        DateTime dateTime = DateTime.now();
                        List listTurnTime = [];
                        List listMaintainanceHour = [];
                        int? maintenance;
                        for (var assetData in newlist) {
                          if (assetData.fault != '') {
                            var turnOn = assetData.turnOn;
                            print(turnOn);
                            var shutDown = assetData.shutDown;
                            print(shutDown);
                            Duration maintainanceHour;
                            if (shutDown == null || turnOn == null) {
                              maintenance = 0;
                              listMaintainanceHour.add(maintenance);
                              listTurnTime.add(assetData.shutDown);
                            } else {
                              maintainanceHour = turnOn.difference(shutDown);
                              maintenance = maintainanceHour.inSeconds;
                              listMaintainanceHour.add(maintenance);
                              listTurnTime.add(assetData.shutDown);
                            }
                          }
                        }
                        DateTime tDateTime = calcMaxDate(listTurnTime);
                        Duration dtat = dateTime.difference(tDateTime);
                        int operationHOur = dtat.inSeconds + maintenance!;
                        double mtbf =
                            operationHOur / listMaintainanceHour.length;
                        double failureRate = -hoursValue / mtbf;
                        var predictValue = exp(failureRate);
                        predictResult = predictValue;
                      }

                      if (_formKey.currentState!.validate()) {
                        hours = int.parse(_hourTextController.text);
                        await _getReliability(hours);
                        setState(() {});
                      }
                    },
                    child: const Text('Predict',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900))),
              ),
            ])),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(
                child: Text(
              '${(predictResult * 100).toStringAsFixed(2)} %',
              style: Theme.of(context).textTheme.headlineMedium,
            ))),
      ],
    );
  }

  Column details(BuildContext context, String? assetid) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Center(
              child: Text(
            '${widget.assetName}',
            style: Theme.of(context).textTheme.headlineMedium,
          )),
        ),
        const Divider(
          color: Colors.black,
          height: 0.5,
        ),
        widget.imageUrl == null || widget.imageUrl =="" ? Container() :
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.contain,
              image: CachedNetworkImageProvider(widget.imageUrl!))
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Assign to a Location'),
            Text(''),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'worker Assigned To',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(''),
          ],
        ),
        TextButton(onPressed: () {}, child: const Text('Add to New Worker')),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Asset Active / Inactive'),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assets')
                    .doc(assetid)
                    .collection('assetsData')
                    .where('assetid', isEqualTo: assetid)
                    .where('turnOn', isNull: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('loading.......');
                  }
                  if (snapshot.hasError) {
                    return const Text('No Data Available');
                  }
                  final assetDetails = snapshot.data!.docs.map((docs) {
                    return AssetDataModel.fromDocument(docs).active;
                  }).toList();
                  final assetDetailID = snapshot.data!.docs.map((docs) {
                    return AssetDataModel.fromDocument(docs).id;
                  }).toList();
                  bool? assetState;
                  assetDetails.isEmpty
                      ? assetState = true
                      : assetState = assetDetails[0];
                  return Switch(
                    value: assetState == _giveVerse ? _giveVerse : false,
                    onChanged: (bool newValue) async {
                      if (newValue == true) {
                        await AssetDataViewModel().updateAssetData(
                            context: context,
                            turnOn: DateTime.now(),
                            assetid: assetid,
                            assetDataid: assetDetailID[0],
                            active: true);
                      }

                      setState(() {
                        _giveVerse = newValue;
                      });
                      if (_giveVerse == false) {
                        // ignore: use_build_context_synchronously
                        await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                return AlertDialog(
                                  title: const Text('Asset Log'),
                                  content: Column(
                                    children: [
                                      DropdownButtonFormField(
                                        value: _selectedValue,
                                        isExpanded: true,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedValue = value!;
                                          });
                                        },
                                        onSaved: (String? value) {
                                          setState(() {
                                            _selectedValue = value!;
                                          });
                                        },
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return "can't empty";
                                          } else {
                                            return null;
                                          }
                                        },
                                        items: listOfValue.map((String val) {
                                          return DropdownMenuItem(
                                            value: val,
                                            child: Text(
                                              val,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      _selectedValue == 'Fault'
                                          ? TextField(
                                              decoration: const InputDecoration(
                                                  hintText: 'Enter Fault'),
                                              onChanged: (value) {
                                                fault = value;
                                              },
                                            )
                                          : Container(),
                                      validation == false
                                          ? Text(
                                              validationMessage,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            )
                                          : Container()
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _giveVerse = true;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel')),
                                    ElevatedButton(
                                        onPressed: () {
                                          if (fault == '' &&
                                              _selectedValue != 'Normal') {
                                            setState(() {
                                              validation = false;
                                            });
                                          }
                                          if (fault.isNotEmpty ||
                                              _selectedValue == 'Normal') {
                                            DateTime dateTime = DateTime.now();
                                            addAssetDetail.addAssetData(
                                                assetid: assetid!,
                                                active: false,
                                                fault: fault,
                                                shutDown: dateTime,
                                                context: context);

                                            setState(() {
                                              _giveVerse = false;
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Submit'))
                                  ],
                                );
                              });
                            });
                        setState(() {});
                      } else {
                        String? assetDataid = await _getAssetID();
                        if (assetDataid != null) {
                          // ignore: use_build_context_synchronously
                          AssetDataViewModel().updateAssetData(
                              assetid: assetid,
                              assetDataid: assetDataid,
                              active: true,
                              turnOn: DateTime.now(),
                              context: context);
                        }
                      }
                    },
                  );
                }),
          ],
        ),
      ],
    );
  }

  Column availability(BuildContext context) {
    return const Column(children: [
      SizedBox(
        height: 20,
      ),
    ]);
  }
}
