import 'package:confetti/confetti.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'segment.dart';
import 'shirt.dart';

/// Defines display ordering for segments
enum DisplayOrder { ascending, descending }

/// A Flame-based shirt folding game using Shirt model
class ShirtGame extends FlameGame with PanDetector {
  Color bgColor = Colors.white;
  final String frontImagePath;
  final String backImagePath;
  final void Function(List<List<List<Segment>>>) onGridUpdate;

  late Shirt shirt;
  static const int rows = 2;
  static const int cols = 4;

  /// Keep track of any temporary highlight rectangles
  final List<RectangleComponent> _highlightRects = [];

  /// Control display order of segments
  DisplayOrder displayOrder = DisplayOrder.ascending;

  /// Track drag start and end segments
  Segment? _dragStartSegment;
  Segment? _dragLastSegment;

  late double segmentWidth;
  late double segmentHeight;
  late ConfettiController _confetti;

  ShirtGame({
    required this.frontImagePath,
    required this.backImagePath,
    required this.onGridUpdate,
  });

  @override
  Color backgroundColor() => bgColor;

  @override
  Future<void> onLoad() async {
    final frontSprite = await loadSprite(frontImagePath);
    final backSprite = await loadSprite(backImagePath);
    final texSize = frontSprite.srcSize;

    segmentWidth = size.x / cols;
    segmentHeight = size.y / rows;
    final srcW = texSize.x / cols;
    final srcH = texSize.y / rows;

    // initialize Shirt with first 8 segments
    final initial = <Segment>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        initial.add(Segment(
          id: '${r}_$c',
          frontImage: frontSprite.image,
          backImage: backSprite.image,
          srcPosition: Vector2(c * srcW, r * srcH),
          srcSize: Vector2(srcW, srcH),
          size: Vector2(segmentWidth, segmentHeight),
          row: r,
          col: c,
        ));
      }
    }
    shirt = Shirt(
      s0: initial[0], s1: initial[1], s2: initial[2], s3: initial[3],
      s4: initial[4], s5: initial[5], s6: initial[6], s7: initial[7],
    );

    _updatePositions();
    _confetti = ConfettiController(duration: const Duration(seconds: 5));
  }

  /// Updates position and rendering order of all segments
  void _updatePositions() {
    children.clear();
    final offsetX = (size.x - cols * segmentWidth) / 2;
    final offsetY = (size.y - rows * segmentHeight) / 2;
    final grid = shirt.grid;

    for (var r = 0; r < grid.length; r++) {
      for (var c = 0; c < grid[r].length; c++) {
        final cell = grid[r][c];
        for (var i = 0; i < cell.length; i++) {
          final seg = cell[i];
          seg.position = Vector2(
            offsetX + c * segmentWidth,
            offsetY + r * segmentHeight,
          );
          seg.priority = i;
          add(seg);
        }
      }
    }
  }

  void flipAll() {
    shirt.reverseReload();
    _updatePositions();
    onGridUpdate(shirt.grid);
  }

  @override
  void onPanStart(DragStartInfo info) {
    _dragStartSegment = _hitSegment(info.eventPosition.global);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _dragLastSegment = _hitSegment(info.eventPosition.global);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_dragStartSegment != null && _dragLastSegment != null) {
      final moved = shirt.determineMovement(
        _dragStartSegment!.row,
        _dragStartSegment!.col,
        _dragLastSegment!.row,
        _dragLastSegment!.col,
      );
      if (moved) {
        _updatePositions();
        onGridUpdate(shirt.grid);
        _confetti.play();
      }
    }
    _dragStartSegment = null;
    _dragLastSegment = null;
  }

  Segment? _hitSegment(Vector2 pos) {
    for (final s in children.whereType<Segment>()) {
      if (s.toRect().contains(pos.toOffset())) {
        return s;
      }
    }
    return null;
  }

  /// Highlights one cell for [duration]
  void highlightSection(int row, int col, Color color, Duration duration) {
    final offsetX = (size.x - cols * segmentWidth) / 2;
    final offsetY = (size.y - rows * segmentHeight) / 2;
    final rectComp = RectangleComponent(
      position: Vector2(
        offsetX + col * segmentWidth,
        offsetY + row * segmentHeight,
      ),
      size: Vector2(segmentWidth, segmentHeight),
      paint: Paint()..color = color.withOpacity(0.5),
    );
    add(rectComp);
    _highlightRects.add(rectComp);
    Future.delayed(duration, () {
      remove(rectComp);
      _highlightRects.remove(rectComp);
    });
  }

  /// Highlights every grid section once with varied hues
  void highlightAllSections(Duration duration,) {
    final total = rows * cols;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final idx = r * cols + c;
        final hue = (idx * (360.0 / total)) % 360.0;
        final color = HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
        highlightSection(r, c, color, duration);
      }
    }
  }

   void firstNonEmptySegment() {
    if (shirt.topLeft.isNotEmpty) {
      highlightSection(0,0,Colors.greenAccent,Duration(seconds: 1));
    }
    else if (shirt.topRight.isNotEmpty) {
      highlightSection(0,3,Colors.greenAccent,Duration(seconds: 1));
    }
    else{
      if (shirt.bottomCenterRight.isNotEmpty) {
        highlightSection(1,2,Colors.greenAccent,Duration(seconds: 1));
     }
      if (shirt.bottomCenterLeft.isNotEmpty) {
       highlightSection(1,1,Colors.greenAccent,Duration(seconds: 1));
     }
    }
  }
}