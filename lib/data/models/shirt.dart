import 'package:shirt_base/data/models/segment.dart';
import 'direction.dart';

class Shirt {
  List<Segment> topLeft = [];
  List<Segment> topCenterLeft = [];
  List<Segment> topCenterRight = [];
  List<Segment> topRight = [];

  List<Segment> bottomLeft = [];
  List<Segment> bottomCenterLeft = [];
  List<Segment> bottomCenterRight = [];
  List<Segment> bottomRight = [];

  int _nextIndex = 0;

  Shirt({
    required Segment s0,
    required Segment s1,
    required Segment s2,
    required Segment s3,
    required Segment s4,
    required Segment s5,
    required Segment s6,
    required Segment s7,
  }) {
    topLeft.add(s0);
    topCenterLeft.add(s1);
    topCenterRight.add(s2);
    topRight.add(s3);
    bottomLeft.add(s4);
    bottomCenterLeft.add(s5);
    bottomCenterRight.add(s6);
    bottomRight.add(s7);
  }

  List<List<List<Segment>>> get grid => [
    [topLeft, topCenterLeft, topCenterRight, topRight],
    [bottomLeft, bottomCenterLeft, bottomCenterRight, bottomRight],
  ];

  void add(Segment segment) {
    switch (_nextIndex) {
      case 0:
        topLeft.add(segment);
        break;
      case 1:
        topCenterLeft.add(segment);
        break;
      case 2:
        topCenterRight.add(segment);
        break;
      case 3:
        topRight.add(segment);
        break;
      case 4:
        bottomLeft.add(segment);
        break;
      case 5:
        bottomCenterLeft.add(segment);
        break;
      case 6:
        bottomCenterRight.add(segment);
        break;
      case 7:
        bottomRight.add(segment);
        break;
      default:
        throw Exception('تمت إضافة جميع الأقسام الثمانية بالفعل!');
    }
    _nextIndex++;
  }

  void foldRightVertical() {
    for (final segment in topRight.reversed) {
      segment.toggle(direction: FlipDirection.vertical);
      topCenterRight.add(segment);
    }
    topRight.clear();

    for (final segment in bottomRight.reversed) {
      segment.toggle(direction: FlipDirection.vertical);
      bottomCenterRight.add(segment);
    }
    bottomRight.clear();
  }

  void foldLeftVertical() {
    for (final segment in topLeft.reversed) {
      segment.toggle(direction: FlipDirection.vertical);
      topCenterLeft.add(segment);
    }
    topLeft.clear();

    for (final segment in bottomLeft.reversed) {
      segment.toggle(direction: FlipDirection.vertical);
      bottomCenterLeft.add(segment);
    }
    bottomLeft.clear();
  }

  void foldAroundMiddleAxis({
    HorizontalDirection? horizontalDirection,
    VerticalDirection? verticalDirection,
  }) {
    if (horizontalDirection != null) {
      switch (horizontalDirection) {
        case HorizontalDirection.leftToRight:
          for (final segment in topCenterLeft.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            topCenterRight.add(segment);
          }
          topCenterLeft.clear();

          for (final segment in bottomCenterLeft.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            bottomCenterRight.add(segment);
          }
          bottomCenterLeft.clear();

          for (final segment in topLeft.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            topRight.add(segment);
          }
          topLeft.clear();

          for (final segment in bottomLeft.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            bottomRight.add(segment);
          }
          bottomLeft.clear();
          break;

        case HorizontalDirection.rightToLeft:
          for (final segment in topCenterRight.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            topCenterLeft.add(segment);
          }
          topCenterRight.clear();

          for (final segment in bottomCenterRight.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            bottomCenterLeft.add(segment);
          }
          bottomCenterRight.clear();

          for (final segment in topRight.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            topLeft.add(segment);
          }
          topRight.clear();

          for (final segment in bottomRight.reversed) {
            segment.toggle(direction: FlipDirection.vertical);
            bottomLeft.add(segment);
          }
          bottomRight.clear();
          break;
      }
    }

    if (verticalDirection != null) {
      switch (verticalDirection) {
        case VerticalDirection.topToBottom:
          for (final segment in topCenterLeft.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            bottomCenterLeft.add(segment);
          }
          topCenterLeft.clear();

          for (final segment in topCenterRight.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            bottomCenterRight.add(segment);
          }
          topCenterRight.clear();

          for (final segment in topLeft.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            bottomLeft.add(segment);
          }
          topLeft.clear();

          for (final segment in topRight.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            bottomRight.add(segment);
          }
          topRight.clear();
          break;

        case VerticalDirection.bottomToTop:
          for (final segment in bottomCenterLeft.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            topCenterLeft.add(segment);
          }
          bottomCenterLeft.clear();

          for (final segment in bottomCenterRight.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            topCenterRight.add(segment);
          }
          bottomCenterRight.clear();

          for (final segment in bottomLeft.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            topLeft.add(segment);
          }
          bottomLeft.clear();

          for (final segment in bottomRight.reversed) {
            segment.toggle(direction: FlipDirection.horizontal);
            topRight.add(segment);
          }
          bottomRight.clear();
          break;
      }
    }
  }

  bool determineMovement(int row1, int col1, int row2, int col2,) {
    if (row1 == row2 && col1 == col2) {
      return false;
    }

    // 1 > 2
    // 5 > 6
    else if ((row1 == 0 && col1 == 0 && row2 == 0 && col2 == 1) ||
        (row1 == 1 && col1 == 0 && row2 == 1 && col2 == 1)) {
      foldLeftVertical();
      return true;
    }

    // 4 > 3
    // 8 > 7
    else if ((row1 == 0 && col1 == 3 && row2 == 0 && col2 == 2) ||
        (row1 == 1 && col1 == 3 && row2 == 1 && col2 == 2)) {
      foldRightVertical();
      return true;
    }


    // 1 > 4
    // 5 > 8
    else if ((row1 == 0 && col1 == 0 && row2 == 0 && col2 == 3) ||
        (row1 == 1 && col1 == 0 && row2 == 1 && col2 == 3)) {
      foldAroundMiddleAxis(horizontalDirection: HorizontalDirection.leftToRight);
      return true;
    }

    // 4 > 1
    // 8 > 5
    else if ((row1 == 0 && col1 == 3 && row2 == 0 && col2 == 0) ||
        (row1 == 1 && col1 == 3 && row2 == 1 && col2 == 0)) {
      foldAroundMiddleAxis(horizontalDirection: HorizontalDirection.rightToLeft);
      return true;
    }

    // 1 > 5
    // 2 > 6
    // 3 > 7
    // 4 > 8
    else if ((row1 == 0 && col1 == 0 && row2 == 1 && col2 == 0) ||
        (row1 == 0 && col1 == 1 && row2 == 1 && col2 == 1) ||
        (row1 == 0 && col1 == 2 && row2 == 1 && col2 == 2) ||
        (row1 == 0 && col1 == 3 && row2 == 1 && col2 == 3)) {
      foldAroundMiddleAxis(verticalDirection: VerticalDirection.topToBottom);
      return true;
    }

    // 5 > 1
    // 6 > 2
    // 7 > 3
    // 8 > 4
    else if ((row1 == 1 && col1 == 0 && row2 == 0 && col2 == 0) ||
        (row1 == 1 && col1 == 1 && row2 == 0 && col2 == 1) ||
        (row1 == 1 && col1 == 2 && row2 == 0 && col2 == 2) ||
        (row1 == 1 && col1 == 3 && row2 == 0 && col2 == 3)) {
      foldAroundMiddleAxis(verticalDirection: VerticalDirection.bottomToTop);
      return true;

    }
    return false;
  }

  void reverseReload() {
    final allSegments = [
      topLeft,
      topCenterLeft,
      topCenterRight,
      topRight,
      bottomLeft,
      bottomCenterLeft,
      bottomCenterRight,
      bottomRight,
    ];

    for (int i = 0; i < allSegments.length; i++) {
      List<Segment> reversed = allSegments[i].reversed.map((segment) {
        final newSegment = segment.copyWith(
          frontImage: segment.backImage,
          backImage: segment.frontImage,
        );
        return newSegment;
      }).toList();

      allSegments[i]
        ..clear()
        ..addAll(reversed);
    }
  }
}