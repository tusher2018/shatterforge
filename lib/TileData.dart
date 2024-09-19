import 'package:flutter/material.dart';

class TileModel {
  Offset position;
  String shape;
  Color color;
  String? orientation;
  String? basePosition;
  double? rotationAngle;

  TileModel({
    required this.position,
    this.shape = 'Rectangle',
    this.color = Colors.blueAccent,
    this.orientation,
    this.basePosition,
    this.rotationAngle,
  });

  void updateShape(String newShape) {
    shape = newShape;
  }

  void updateColor(Color newColor) {
    color = newColor;
  }

  void updateOrientation(String newOrientation) {
    orientation = newOrientation;
  }

  void updateBasePosition(String newPosition) {
    basePosition = newPosition;
  }

  void updateRotationAngle(double newAngle) {
    rotationAngle = newAngle;
  }

  Map<String, dynamic> toMap() {
    return {
      'position': {'dx': position.dx, 'dy': position.dy},
      'shape': shape,
      'color': color.value,
      'orientation': orientation,
      'basePosition': basePosition,
      'rotationAngle': rotationAngle,
    };
  }

  factory TileModel.fromMap(Map<String, dynamic> map) {
    return TileModel(
      position: Offset(map['position']['dx'], map['position']['dy']),
      shape: map['shape'],
      color: Color(map['color']),
      orientation: map['orientation'],
      basePosition: map['basePosition'],
      rotationAngle: map['rotationAngle'],
    );
  }
}

class GridData {
  Map<Offset, TileModel> tileAttributes;
  int row;
  int column;

  GridData({
    required this.tileAttributes,
    required this.row,
    required this.column,
  });

  Map<String, dynamic> toMap() {
    Map<String, Map<String, dynamic>> tileAttributesToSave = tileAttributes.map(
      (offset, tileModel) {
        String offsetKey =
            '${offset.dx},${offset.dy}'; // Convert Offset to string
        return MapEntry(
            offsetKey, tileModel.toMap()); // Convert TileModel to map
      },
    );
    return {
      'tileAttributes': tileAttributesToSave,
      'row': row,
      'column': column
    };
  }

  // Converts a Map from Firestore back to GridData
  factory GridData.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> storedTileAttributes =
        map['tileAttributes'] as Map<String, dynamic>;
    return GridData(
      row: map['row'],
      column: map['column'],
      tileAttributes: storedTileAttributes.map(
        (offsetString, tileData) {
          // Convert the offset string back to Offset
          List<String> parts = offsetString.split(',');
          Offset offset =
              Offset(double.parse(parts[0]), double.parse(parts[1]));

          // Convert the map back to TileModel
          TileModel tileModel =
              TileModel.fromMap(tileData as Map<String, dynamic>);

          return MapEntry(offset, tileModel);
        },
      ),
    );
  }
}
