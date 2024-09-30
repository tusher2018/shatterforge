import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:shatterforge/GridPainter.dart';

import 'package:shatterforge/TileData.dart';
import 'package:shatterforge/src/components/commonText.dart';

class MapCreatePage extends StatefulWidget {
  @override
  _MapCreatePageState createState() => _MapCreatePageState();
}

class _MapCreatePageState extends State<MapCreatePage> {
  int defaultRow = 10;
  int defaultColumn = 10;
  int row = 10;
  int like = 0, dislike = 0, hard = 0, easy = 0, medium = 0;
  int column = 10;
  Offset? selectedTile;
  int unBreakable = 0;

  String selectedShape = 'Rectangle';
  String selectedOrientation = 'Bottom-left';
  String selectedBasePosition = "Bottom";
  Color currentColor = Colors.blueAccent;
  String selectedBrickType = brickTypes[0].name;

  double selectedRotationAngle = 0;
  Map<String, int> brickCounts = {
    'Standard': 0,
    'Unbreakable': 0,
    'Explosive': 0,
    'Healing': 0,
    'Invisible': 0,
    'Speed': 0,
    'Multi-Hit': 0,
    'Power-Up': 0,
    'Shifting': 0,
    'Special': 0,
  };

  int totalBricks = 100;

  Map<Offset, TileModel> tileAttributes = {};

  @override
  void initState() {
    super.initState();
    _importGrid();
  }

  void onTapDown(TapDownDetails details, Size gridSize) {
    double tileWidth = gridSize.width / column;
    double tileHeight = gridSize.height / row;
    int tappedRow = (details.localPosition.dy / tileHeight).floor();
    int tappedColumn = (details.localPosition.dx / tileWidth).floor();
    Offset tappedTile = Offset(tappedColumn.toDouble(), tappedRow.toDouble());
    setState(() {
      selectedTile = tappedTile;

      if (!tileAttributes.containsKey(tappedTile)) {
        if (addBrick(selectedBrickType)) {
          int currentIndex =
              brickTypes.indexWhere((type) => type.name == selectedBrickType);

          tileAttributes[tappedTile] = TileModel(
              position: tappedTile,
              color: (selectedBrickType == "Invisible")
                  ? Colors.transparent
                  : currentColor,
              brickType: brickTypes[currentIndex],
              shape: selectedShape);
        } else {
          for (int i = 0; i < brickTypes.length; i++) {
            selectedBrickType = brickTypes[i].name;
            if (addBrick(selectedBrickType)) {
              tileAttributes[tappedTile] = TileModel(
                  position: tappedTile,
                  color: currentColor,
                  brickType: brickTypes[i],
                  shape: selectedShape);

              break;
            }
          }
        }
        // tileAttributes[tappedTile] = TileModel(
        //     position: tappedTile, color: currentColor, shape: selectedShape);
      } else {
        selectedShape = tileAttributes[tappedTile]!.shape;
        if (tileAttributes[tappedTile]!.color != Colors.transparent) {
          currentColor = tileAttributes[tappedTile]!.color;
        }
        selectedBrickType = tileAttributes[tappedTile]!.brickType.name;
        if (tileAttributes[tappedTile]!.orientation != null) {
          selectedOrientation = tileAttributes[tappedTile]!.orientation!;
        }
        if (tileAttributes[tappedTile]!.rotationAngle != null) {
          selectedRotationAngle = tileAttributes[tappedTile]!.rotationAngle!;
        }
        if (tileAttributes[tappedTile]!.basePosition != null) {
          selectedBasePosition = tileAttributes[tappedTile]!.basePosition!;
        }
      }
    });
  }

  void _exportGrid() async {
    if (FirebaseAuth.instance.currentUser == null) {
      showCommonSnackbar(
        context,
        message: 'Please join to create your 1st map.',
        icon: Icons.error,
      );
      return;
    }
    try {
      GridData gridData = GridData(
          userId: FirebaseAuth.instance.currentUser!.uid,
          row: row,
          column: column,
          dislike: dislike,
          like: like,
          hard: hard,
          easy: easy,
          medium: medium,
          tileAttributes: tileAttributes,
          isPlayable: true);
      await FirebaseFirestore.instance
          .collection('Maps')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(gridData.toMap());

      print('Tile attributes successfully saved to Firestore');
      showCommonSnackbar(
        context,
        message: 'Map successfully Updated.',
        icon: Icons.save,
      );
    } catch (e) {
      print('Error saving tile attributes to Firestore: $e');
      showCommonSnackbar(
        context,
        message: 'An error occoured map could not saved successfully.',
        icon: Icons.error,
      );
    }
  }

  void _importGrid() async {
    try {
      // Retrieve the document from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Maps')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        GridData gridData = GridData.fromMap(data);

        row = gridData.row;
        column = gridData.column;
        totalBricks = row * column;
        easy = gridData.easy;
        medium = gridData.medium;
        hard = gridData.hard;
        dislike = gridData.dislike;
        like = gridData.like;

        tileAttributes = gridData.tileAttributes;

        setState(() {});
        print('Tile attributes successfully loaded from Firestore');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error loading tile attributes from Firestore: $e');
    }
  }

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
      if (selectedTile != null) {
        tileAttributes[selectedTile!]!.updateColor(color);
      }
    });
  }

  bool canAddBrick(String brickType, int currentTotalBricks) {
    int currentCount = brickCounts[brickType] ?? 0;
    int maxAllowed =
        (brickTypes.firstWhere((type) => type.name == brickType).maxPercentage *
                totalBricks) ~/
            100;

    return currentCount < maxAllowed;
  }

  bool addBrick(String brickType) {
    int currentTotalBricks = brickCounts.values.reduce((a, b) => a + b);

    if (canAddBrick(brickType, currentTotalBricks)) {
      brickCounts[brickType] = (brickCounts[brickType] ?? 0) + 1;
      print('Added $brickType brick');
      return true;
    } else {
      print('Cannot add more $brickType bricks, limit reached');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Expanded(
                flex: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) => onTapDown(details,
                          Size(constraints.maxWidth, constraints.maxHeight)),
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: GridPainter(row, column, tileAttributes),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                      labelText: 'Rows',
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2)),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide:
                                              BorderSide(color: Colors.white, width: 2)),
                                      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  onChanged: (value) {
                                    setState(() {
                                      row = int.tryParse(value) ?? defaultRow;
                                      totalBricks = row * column;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                      labelText: 'Columns',
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2)),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide:
                                              BorderSide(color: Colors.white, width: 2)),
                                      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  onChanged: (value) {
                                    setState(() {
                                      column =
                                          int.tryParse(value) ?? defaultColumn;
                                      totalBricks = row * column;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (selectedTile != null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText("Color", isBold: true),
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: commonText(
                                                        'Pick a color'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ColorPicker(
                                                        pickerColor:
                                                            currentColor,
                                                        onColorChanged:
                                                            changeColor,
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: commonText(
                                                            'DONE',
                                                            color:
                                                                Colors.black),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 24,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                color: currentColor,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          color: currentColor.withOpacity(0.3),
                                        ),
                                        child: Center(
                                          child: commonText(
                                              "R${selectedTile!.dy.toInt()}, C${selectedTile!.dx.toInt()}",
                                              size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: commonText("Shape", isBold: true),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: DropdownButton<String>(
                                              dropdownColor: Colors.black54,
                                              value: selectedShape,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedShape = value!;

                                                  if (selectedTile != null) {
                                                    tileAttributes[
                                                            selectedTile!]!
                                                        .shape = value;
                                                  }
                                                });
                                              },
                                              items: [
                                                'Ellipse',
                                                'Triangle',
                                                'Right Triangle',
                                                'Rectangle',
                                                'Parallelogram',
                                                'Trapezium',
                                                'Pentagon',
                                                'Hexagon',
                                                'Kite',
                                              ].map((shape) {
                                                return DropdownMenuItem(
                                                  value: shape,
                                                  child: commonText(shape,
                                                      isBold: true),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                //break type
                                Row(
                                  children: [
                                    Expanded(
                                      child: commonText("Brick type",
                                          isBold: true),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FittedBox(
                                            child: DropdownButton<String>(
                                              dropdownColor: Colors.black54,
                                              value: selectedBrickType,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedBrickType = newValue!;

                                                  if (selectedTile != null) {
                                                    int index = brickTypes
                                                        .indexWhere((type) =>
                                                            type.name ==
                                                            newValue);
                                                    tileAttributes[
                                                                selectedTile!]!
                                                            .brickType =
                                                        brickTypes[index];
                                                    if (newValue ==
                                                        "Invisible") {
                                                      tileAttributes[
                                                                  selectedTile!]!
                                                              .color =
                                                          Colors.transparent;
                                                    }
                                                  }
                                                });
                                              },
                                              items: brickTypes
                                                  .map((BrickType brickType) {
                                                return DropdownMenuItem<String>(
                                                  value: brickType.name,
                                                  child: commonText(
                                                      brickType.name),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                //break type end

                                Visibility(
                                  visible: selectedShape == "Right Triangle",
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: commonText(
                                            "Triangle Orientation",
                                            isBold: true),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: DropdownButton<String>(
                                                value: selectedOrientation,
                                                dropdownColor: Colors.black54,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedOrientation =
                                                        value!;
                                                    if (selectedTile != null) {
                                                      tileAttributes[
                                                              selectedTile!]!
                                                          .orientation = value;
                                                    }
                                                  });
                                                },
                                                items: [
                                                  'Bottom-left',
                                                  'Top-left',
                                                  'Bottom-right',
                                                  'Top-right',
                                                ].map((orientation) {
                                                  return DropdownMenuItem(
                                                    value: orientation,
                                                    child: commonText(
                                                        orientation,
                                                        isBold: true),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: selectedShape == "Triangle" ||
                                      selectedShape == "Trapezium" ||
                                      selectedShape == "Parallelogram",
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: commonText(
                                          "Base Position",
                                          isBold: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: DropdownButton<String>(
                                                value: selectedBasePosition,
                                                dropdownColor: Colors.black54,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedBasePosition =
                                                        value!;
                                                    if (selectedTile != null) {
                                                      tileAttributes[
                                                              selectedTile!]!
                                                          .basePosition = value;
                                                    }
                                                  });
                                                },
                                                items: [
                                                  'Bottom',
                                                  'Top',
                                                  'Left',
                                                  'Right',
                                                ].map((basePosition) {
                                                  return DropdownMenuItem(
                                                    value: basePosition,
                                                    child: commonText(
                                                        basePosition,
                                                        isBold: true),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: selectedShape == "Pentagon" ||
                                      selectedShape == "Hexagon",
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: commonText(
                                          "Polygon Rotation Angle",
                                          isBold: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: selectedRotationAngle,
                                          min: 0,
                                          max: 3.141592653589793 * 2,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedRotationAngle = value;
                                              if (selectedTile != null) {
                                                tileAttributes[selectedTile!]!
                                                    .rotationAngle = value;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          commonButton(context, "Save", _exportGrid),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
