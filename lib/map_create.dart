import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math' as Math;

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
  int column = 10;
  Offset? selectedTile;

  String selectedShape = 'Rectangle';
  String selectedOrientation = 'Bottom-left';
  String selectedBasePosition = "Bottom";
  Color currentColor = Colors.blueAccent;

  double selectedRotationAngle = 0;

  Map<Offset, TileModel> tileAttributes = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callLoader();
  }

  void onTapDown(TapDownDetails details, Size gridSize) {
    double tileWidth = gridSize.width / column;
    double tileHeight = gridSize.height / row;
    int tappedRow = (details.localPosition.dy / tileHeight).floor();
    int tappedColumn = (details.localPosition.dx / tileWidth).floor();
    Offset tappedTile = Offset(tappedColumn.toDouble(), tappedRow.toDouble());

    setState(() {
      selectedTile = tappedTile;
      // If tapped tile does not exist, create a new TileModel
      if (!tileAttributes.containsKey(tappedTile)) {
        tileAttributes[tappedTile] = TileModel(
            position: tappedTile, color: currentColor, shape: selectedShape);
      } else {
        selectedShape = tileAttributes[tappedTile]!.shape;
        currentColor = tileAttributes[tappedTile]!.color;
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
    try {
      GridData gridData =
          GridData(row: row, column: column, tileAttributes: tileAttributes);
      await FirebaseFirestore.instance
          .collection('tileData')
          .doc('yourDocumentId')
          .set(gridData.toMap());

      print('Tile attributes successfully saved to Firestore');
    } catch (e) {
      print('Error saving tile attributes to Firestore: $e');
    }
  }

  void callLoader() async {
    await loadTileAttributesFromFirestore();
  }

  Future<void> loadTileAttributesFromFirestore() async {
    try {
      // Retrieve the document from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('tileData')
          .doc('yourDocumentId')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        GridData gridData = GridData.fromMap(data);

        row = gridData.row;
        column = gridData.column;
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

  void updateTileShape(String shape) {
    setState(() {
      selectedShape = shape;
      if (selectedTile != null) {
        tileAttributes[selectedTile!]!.updateShape(shape);
      }
    });
  }

  void updateTileOrientation(String orientation) {
    setState(() {
      selectedOrientation = orientation;
      if (selectedTile != null &&
          tileAttributes[selectedTile!]!.shape == 'Right Triangle') {
        tileAttributes[selectedTile!]!.updateOrientation(orientation);
      }
    });
  }

  void updateBasePosition(String basePosition) {
    setState(() {
      selectedBasePosition = basePosition;
      if (selectedTile != null &&
          (tileAttributes[selectedTile!]!.shape == 'Triangle' ||
              tileAttributes[selectedTile!]!.shape == 'Parallelogram' ||
              tileAttributes[selectedTile!]!.shape == 'Trapezium')) {
        tileAttributes[selectedTile!]!.updateBasePosition(basePosition);
      }
    });
  }

  void updateRotationAngle(double angle) {
    setState(() {
      selectedRotationAngle = angle;
      if (selectedTile != null &&
          (tileAttributes[selectedTile!]!.shape == 'Pentagon' ||
              tileAttributes[selectedTile!]!.shape == 'Hexagon')) {
        tileAttributes[selectedTile!]!.updateRotationAngle(angle);
      }
    });
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

class GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final Map<Offset, TileModel> tileAttributes;

  GridPainter(this.rows, this.columns, this.tileAttributes);

  @override
  void paint(Canvas canvas, Size size) {
    double tileWidth = size.width / columns;
    double tileHeight = size.height / rows;

    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        Rect tileRect = Rect.fromLTWH(
            col * tileWidth, row * tileHeight, tileWidth, tileHeight);
        Offset tileOffset = Offset(col.toDouble(), row.toDouble());

        TileModel? attributes = tileAttributes[tileOffset];
        if (attributes != null) {
          Paint fillPaint = Paint()
            ..color = attributes.color
            ..style = PaintingStyle.fill;

          switch (attributes.shape) {
            case 'Ellipse':
              canvas.drawOval(tileRect, fillPaint);
              break;
            case 'Triangle':
              _drawTriangle(canvas, fillPaint, tileRect,
                  basePosition: attributes.basePosition ?? 'Bottom');
              break;
            case 'Right Triangle':
              _drawRightTriangle(canvas, fillPaint, tileRect,
                  orientation: attributes.orientation ?? 'Bottom-left');
              break;
            case 'Rectangle':
              canvas.drawRect(tileRect, fillPaint);
              break;
            case 'Parallelogram':
              _drawParallelogram(canvas, fillPaint, tileRect,
                  slantDirection: attributes.basePosition ?? 'Right');
              break;
            case 'Trapezium':
              _drawTrapezoid(canvas, fillPaint, tileRect,
                  basePosition: attributes.basePosition ?? 'Bottom');
              break;
            case 'Hexagon':
              _drawPolygon(canvas, fillPaint, tileRect, 6,
                  rotationAngle: attributes.rotationAngle ?? 0);
              break;
            case 'Pentagon':
              _drawPolygon(canvas, fillPaint, tileRect, 5,
                  rotationAngle: attributes.rotationAngle ?? 0);
              break;
            case 'Kite':
              _drawKite(canvas, fillPaint, tileRect);
              break;
          }
        }

        canvas.drawRect(tileRect, borderPaint);
      }
    }
  }

  void _drawTriangle(Canvas canvas, Paint paint, Rect rect,
      {required String basePosition}) {
    Path path = Path();

    switch (basePosition) {
      case 'Bottom':
        path.moveTo(rect.center.dx, rect.top); // Top vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        break;

      case 'Top':
        path.moveTo(rect.center.dx, rect.bottom); // Bottom vertex
        path.lineTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.right, rect.top); // Top-right vertex
        break;

      case 'Left':
        path.moveTo(rect.right, rect.center.dy); // Right vertex
        path.lineTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Right':
        path.moveTo(rect.left, rect.center.dy); // Left vertex
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRightTriangle(Canvas canvas, Paint paint, Rect rect,
      {required String orientation}) {
    Path path = Path();

    switch (orientation) {
      case 'Bottom-left':
        path.moveTo(rect.left, rect.top); // Top-left
        path.lineTo(rect.right, rect.bottom); // Bottom-right
        path.lineTo(rect.left, rect.bottom); // Bottom-left (90-degree)
        break;

      case 'Top-left':
        path.moveTo(rect.left, rect.bottom); // Bottom-left
        path.lineTo(rect.right, rect.top); // Top-right
        path.lineTo(rect.left, rect.top); // Top-left (90-degree)
        break;

      case 'Bottom-right':
        path.moveTo(rect.right, rect.top); // Top-right
        path.lineTo(rect.left, rect.bottom); // Bottom-left
        path.lineTo(rect.right, rect.bottom); // Bottom-right (90-degree)
        break;

      case 'Top-right':
        path.moveTo(rect.right, rect.bottom); // Bottom-right
        path.lineTo(rect.left, rect.top); // Top-left
        path.lineTo(rect.right, rect.top); // Top-right (90-degree)
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawKite(Canvas canvas, Paint paint, Rect rect) {
    Path path = Path();
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.left, rect.center.dy);
    path.lineTo(rect.center.dx, rect.bottom);
    path.lineTo(rect.right, rect.center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawParallelogram(Canvas canvas, Paint paint, Rect rect,
      {required String slantDirection}) {
    Path path = Path();

    switch (slantDirection) {
      case 'Right':
        // Parallelogram slanting towards the right
        path.moveTo(
            rect.left + rect.width / 4, rect.top); // Top-left vertex (offset)
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right - rect.width / 4,
            rect.bottom); // Bottom-right vertex (offset)
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Left':
        // Parallelogram slanting towards the left
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(
            rect.right - rect.width / 4, rect.top); // Top-right vertex (offset)
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left + rect.width / 4,
            rect.bottom); // Bottom-left vertex (offset)
        break;

      case 'Top':
        // Parallelogram slanting upwards
        path.moveTo(
            rect.left, rect.top + rect.height / 4); // Top-left vertex (offset)
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right,
            rect.bottom - rect.height / 4); // Bottom-right vertex (offset)
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Bottom':
        // Parallelogram slanting downwards
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.right,
            rect.top + rect.height / 4); // Top-right vertex (offset)
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left,
            rect.bottom - rect.height / 4); // Bottom-left vertex (offset)
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTrapezoid(Canvas canvas, Paint paint, Rect rect,
      {required String basePosition}) {
    Path path = Path();

    switch (basePosition) {
      case 'Bottom':
        // Trapezoid with the longer base at the bottom
        path.moveTo(
            rect.left + rect.width / 4, rect.top); // Top-left vertex (offset)
        path.lineTo(
            rect.right - rect.width / 4, rect.top); // Top-right vertex (offset)
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Top':
        // Trapezoid with the longer base at the top
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right - rect.width / 4,
            rect.bottom); // Bottom-right vertex (offset)
        path.lineTo(rect.left + rect.width / 4,
            rect.bottom); // Bottom-left vertex (offset)
        break;

      case 'Left':
        // Trapezoid with the longer base on the left side
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        path.lineTo(rect.right,
            rect.bottom - rect.height / 4); // Bottom-right vertex (offset)
        path.lineTo(rect.right,
            rect.top + rect.height / 4); // Top-right vertex (offset)
        break;

      case 'Right':
        // Trapezoid with the longer base on the right side
        path.moveTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left,
            rect.bottom - rect.height / 4); // Bottom-left vertex (offset)
        path.lineTo(
            rect.left, rect.top + rect.height / 4); // Top-left vertex (offset)
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPolygon(Canvas canvas, Paint paint, Rect rect, int sides,
      {double rotationAngle = 0}) {
    double centerX = rect.center.dx;
    double centerY = rect.center.dy;
    double radius = rect.width / 2;

    Path path = Path();
    double angle = (2 * 3.141592653589793) / sides;

    for (int i = 0; i < sides; i++) {
      // Apply the rotation angle
      double x = centerX + radius * Math.cos(i * angle + rotationAngle);
      double y = centerY + radius * Math.sin(i * angle + rotationAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
