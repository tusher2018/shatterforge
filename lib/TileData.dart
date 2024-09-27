import 'package:flutter/material.dart';

List<BrickType> brickTypes = [
  BrickType('Standard', 100, 100),
  BrickType('Unbreakable', 25, 200),
  BrickType('Explosive', 5, 100),
  BrickType('Healing', 5, 100),
  BrickType('Invisible', 5, 100),
  BrickType('Speed', 5, 100),
  BrickType('Multi-Hit', 10, 100),
  BrickType('Power-Up', 5, 100),
];

class BrickType {
  final String name;
  int health;
  final int maxPercentage;

  BrickType(this.name, this.maxPercentage, this.health);

  // Convert a Map to BrickType (fromMap)
  factory BrickType.fromMap(Map<String, dynamic> map) {
    return BrickType(
      map['name'] as String,
      map['maxPercentage'] as int,
      map['health'] as int,
    );
  }

  // Convert a BrickType to Map (toMap)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'maxPercentage': maxPercentage,
      'health': health,
    };
  }
}

class TileModel {
  Offset position;
  String shape;
  Color color;
  String? orientation;
  String? basePosition;
  double? rotationAngle;
  BrickType brickType;

  TileModel(
      {required this.position,
      this.shape = 'Rectangle',
      this.color = Colors.blueAccent,
      this.orientation,
      this.basePosition,
      this.rotationAngle,
      required this.brickType});

  void updateShape(String newShape) {
    shape = newShape;
  }

  void updateBrickType(BrickType newBrickType) {
    brickType = newBrickType;
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
      'brickType': brickType.toMap()
    };
  }

  factory TileModel.fromMap(Map<String, dynamic> map) {
    late BrickType localBrickType;
    if (map['brickType'] == null) {
      localBrickType = BrickType('Standard', 40, 100);
    } else {
      localBrickType = BrickType.fromMap(map['brickType']);
    }
    return TileModel(
      position: Offset(map['position']['dx'], map['position']['dy']),
      shape: map['shape'],
      color: Color(map['color']),
      orientation: map['orientation'],
      basePosition: map['basePosition'],
      rotationAngle: map['rotationAngle'],
      brickType: localBrickType,
    );
  }
}

class GridData {
  Map<Offset, TileModel> tileAttributes;
  bool isPlayable;
  int row;
  int column;
  int? like, dislike, hard, medium, easy;

  GridData({
    required this.tileAttributes,
    required this.row,
    required this.isPlayable,
    required this.column,
    this.like,
    this.dislike,
    this.easy,
    this.hard,
    this.medium,
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
      'column': column,
      'isPlayable': isPlayable,
      'like': like,
      'dislike': dislike,
      'hard': hard,
      'easy': easy,
      'medium': medium
    };
  }

  // Converts a Map from Firestore back to GridData
  factory GridData.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> storedTileAttributes =
        map['tileAttributes'] as Map<String, dynamic>;
    return GridData(
      isPlayable: map['isPlayable'] ?? false,
      row: map['row'],
      column: map['column'],
      dislike: map['dislike'] ?? 0,
      easy: map['easy'] ?? 0,
      hard: map['hard'] ?? 0,
      like: map['like'] ?? 0,
      medium: map['medium'] ?? 0,
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
