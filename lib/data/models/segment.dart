import 'dart:ui' as ui;
import 'package:flame/components.dart';

class Segment extends SpriteComponent {
  final String id;
  final ui.Image frontImage;
  final ui.Image backImage;
  final Vector2 srcPosition;
  final Vector2 srcSize;
  FlipDirection direction;
  bool flippedVertical;
  bool flippedHorizontal;
  int col;
  int row;

  Segment({
    required this.id,
    required this.frontImage,
    required this.backImage,
    required this.srcPosition,
    required this.srcSize,
    required Vector2 size,
    this.flippedVertical = false,
    this.flippedHorizontal = false,
    this.direction = FlipDirection.none,
    required this.col,
    required this.row,
    priority = 1,
  }) : super(
    sprite: Sprite(
      (flippedVertical == flippedHorizontal) ? frontImage : backImage,
      srcPosition: srcPosition,
      srcSize: srcSize,
    ),
    size: size,
  ) {
    this.priority = priority;

    if(flippedVertical){
      anchor = flippedHorizontal ? Anchor.bottomRight : Anchor.topRight;
      scale.x = -1;
    }

    if(flippedHorizontal){
      anchor = flippedVertical ? Anchor.bottomRight : Anchor.bottomLeft;
      scale.y = -1;
    }
  }

  /// Toggle between front and back image,
  /// maintaining reflection state
  void toggle({FlipDirection direction = FlipDirection.none}) {
    this.direction = direction;

    // Maintain horizontal reflection
    if (direction == FlipDirection.vertical) {
      flippedVertical = !flippedVertical;
    }
    else if( direction == FlipDirection.horizontal) {
      flippedHorizontal = !flippedHorizontal;
    }

    sprite = Sprite(
      currentImage,
      srcPosition: srcPosition,
      srcSize: srcSize,
    );

    if (direction == FlipDirection.vertical) {
      anchor = (flippedHorizontal == flippedVertical) ? Anchor.topLeft : Anchor.topRight;
      scale.x *= -1;
    } else if(direction == FlipDirection.horizontal) {
      anchor = (flippedHorizontal == flippedVertical) ? Anchor.bottomRight : Anchor.bottomLeft;
      scale.y *= -1;
    }
  }

  /// Reflect sprite horizontally around its center
  void reflectHorizontally() {
    scale.x = -scale.x;
  }

  /// Reflect sprite vertically around its center
  void reflectVertically() {
    scale.y = -scale.y;
  }

  /// Returns the currently visible image
  ui.Image get currentImage => (flippedVertical == flippedHorizontal) ? frontImage : backImage;

  /// Creates a copy of this segment with optional new values
  Segment copyWith({
    String? id,
    ui.Image? frontImage,
    ui.Image? backImage,
    Vector2? srcPosition,
    Vector2? srcSize,
    Vector2? size,
    bool? flippedHorizontal,
    bool? flippedVertical,
    FlipDirection? direction,
    int? col,
    int? row,
  }) {
    return Segment(
      id: id ?? this.id,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      srcPosition: srcPosition ?? this.srcPosition.clone(),
      srcSize: srcSize ?? this.srcSize.clone(),
      size: size ?? this.size.clone(),
      flippedHorizontal: flippedHorizontal ?? this.flippedHorizontal,
      flippedVertical: flippedVertical ?? this.flippedVertical,
      direction: direction ?? this.direction,
      col: col ?? this.col,
      row: row ?? this.row,
    );
  }

  @override
  String toString() {
    return 'Segment{'
        'id: $id, '
        'flippedHorizontal: $flippedHorizontal, '
        'flippedVertical: $flippedVertical, '
        'priority: $priority'
        '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is Segment &&
        other.id == id &&
        other.flippedHorizontal == flippedHorizontal &&
        other.flippedVertical == flippedVertical &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      flippedHorizontal,
      flippedVertical,
      priority,
    );
  }

  /// Compare segments based on their position (row and column)
  int compareByPosition(Segment other) {
    final rowComparison = row.compareTo(other.row);
    if (rowComparison != 0) return rowComparison;
    return col.compareTo(other.col);
  }

  /// Compare segments based on their ID
  int compareById(Segment other) {
    return id.compareTo(other.id);
  }
}

enum FlipDirection {
  vertical,
  horizontal,
  none
}