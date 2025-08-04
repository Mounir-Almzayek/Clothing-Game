import 'package:shirt_base/data/models/segment.dart';
import 'direction.dart';

class Pants {
  List<Segment> row0Left = [];
  List<Segment> row0Right = [];
  List<Segment> row1Left = [];
  List<Segment> row1Right = [];
  List<Segment> row2Left = [];
  List<Segment> row2Right = [];
  List<Segment> row3Left = [];
  List<Segment> row3Right = [];

  int _nextIndex = 0;

  Pants({
    required Segment s0,
    required Segment s1,
    required Segment s2,
    required Segment s3,
    required Segment s4,
    required Segment s5,
    required Segment s6,
    required Segment s7,
  }) {
    row0Left.add(s0);
    row0Right.add(s1);
    row1Left.add(s2);
    row1Right.add(s3);
    row2Left.add(s4);
    row2Right.add(s5);
    row3Left.add(s6);
    row3Right.add(s7);
  }

  List<List<List<Segment>>> get grid => [
    [row0Left, row0Right],
    [row1Left, row1Right],
    [row2Left, row2Right],
    [row3Left, row3Right],
  ];

  void add(Segment segment) {
    switch (_nextIndex) {
      case 0:
        row0Left.add(segment);
        break;
      case 1:
        row0Right.add(segment);
        break;
      case 2:
        row1Left.add(segment);
        break;
      case 3:
        row1Right.add(segment);
        break;
      case 4:
        row2Left.add(segment);
        break;
      case 5:
        row2Right.add(segment);
        break;
      case 6:
        row3Left.add(segment);
        break;
      case 7:
        row3Right.add(segment);
        break;
      default:
        throw Exception('All eight segments have already been added!');
    }
    _nextIndex++;
  }

  void foldDownHorizontal() {
    for (final segment in row3Left) {
      segment.toggle(direction: FlipDirection.horizontal);
      row2Left.add(segment);
    }
    row3Left.clear();

    for (final segment in row3Right) {
      segment.toggle(direction: FlipDirection.horizontal);
      row2Right.add(segment);
    }
    row3Right.clear();
  }

  void foldUpHorizontal() {
    for (final segment in row0Left) {
      segment.toggle(direction: FlipDirection.horizontal);
      row1Left.add(segment);
    }
    row0Left.clear();

    for (final segment in row0Right) {
      segment.toggle(direction: FlipDirection.horizontal);
      row1Right.add(segment);
    }
    row0Right.clear();
  }

  void foldAroundMiddleAxis({
    HorizontalDirection? horizontalDirection,
    VerticalDirection? verticalDirection,
  }) {
    if (horizontalDirection != null) {
      switch (horizontalDirection) {
        case HorizontalDirection.leftToRight:
          for (final segment in row0Left) {
            segment.toggle(direction: FlipDirection.vertical);
            row0Right.add(segment);
          }
          row0Left.clear();

          for (final segment in row1Left) {
            segment.toggle(direction: FlipDirection.vertical);
            row1Right.add(segment);
          }
          row1Left.clear();

          for (final segment in row2Left) {
            segment.toggle(direction: FlipDirection.vertical);
            row2Right.add(segment);
          }
          row2Left.clear();

          for (final segment in row3Left) {
            segment.toggle(direction: FlipDirection.vertical);
            row3Right.add(segment);
          }
          row3Left.clear();
          break;

        case HorizontalDirection.rightToLeft:
          for (final segment in row0Right) {
            segment.toggle(direction: FlipDirection.vertical);
            row0Left.add(segment);
          }
          row0Right.clear();

          for (final segment in row1Right) {
            segment.toggle(direction: FlipDirection.vertical);
            row1Left.add(segment);
          }
          row1Right.clear();

          for (final segment in row2Right) {
            segment.toggle(direction: FlipDirection.vertical);
            row2Left.add(segment);
          }
          row2Right.clear();

          for (final segment in row3Right) {
            segment.toggle(direction: FlipDirection.vertical);
            row3Left.add(segment);
          }
          row3Right.clear();
          break;
      }
    }

    if (verticalDirection != null) {
      switch (verticalDirection) {
        case VerticalDirection.topToBottom:
          for (final segment in row0Right) {
            segment.toggle(direction: FlipDirection.horizontal);
            row3Right.add(segment);
          }
          row0Right.clear();

          for (final segment in row0Left) {
            segment.toggle(direction: FlipDirection.horizontal);
            row3Left.add(segment);
          }
          row0Left.clear();

          for (final segment in row1Left) {
            segment.toggle(direction: FlipDirection.horizontal);
            row2Left.add(segment);
          }
          row1Left.clear();

          for (final segment in row1Right) {
            segment.toggle(direction: FlipDirection.horizontal);
            row2Right.add(segment);
          }
          row1Right.clear();
          break;

        case VerticalDirection.bottomToTop:
          for (final segment in row3Right) {
            segment.toggle(direction: FlipDirection.horizontal);
            row0Right.add(segment);
          }
          row3Right.clear();

          for (final segment in row3Left) {
            segment.toggle(direction: FlipDirection.horizontal);
            row0Left.add(segment);
          }
          row3Left.clear();

          for (final segment in row2Left) {
            segment.toggle(direction: FlipDirection.horizontal);
            row1Left.add(segment);
          }
          row2Left.clear();

          for (final segment in row2Right) {
            segment.toggle(direction: FlipDirection.horizontal);
            row1Right.add(segment);
          }
          row2Right.clear();
          break;
      }
    }
  }


  bool determineMovement(int row1, int col1, int row2, int col2) {
    if (row1 == row2 && col1 == col2) {
      return false;
    }

    // 1 > 3
    // 2 > 4
    else if ((row1 == 0 && col1 == 0 && row2 == 1 && col2 == 0) ||
        (row1 == 0 && col1 == 1 && row2 == 1 && col2 == 1)) {
      foldUpHorizontal();
      return true;
    }

    // 8 > 6
    // 7 > 5
    else if ((row1 == 3 && col1 == 1 && row2 == 2 && col2 == 1) ||
        (row1 == 3 && col1 == 0 && row2 == 2 && col2 == 0)) {
      foldDownHorizontal();
      return true;
    }


    // 1 > 7
    // 2 > 8
    else if ((row1 == 0 && col1 == 0 && row2 == 3 && col2 == 0) ||
        (row1 == 0 && col1 == 1 && row2 == 3 && col2 == 1)) {
      foldAroundMiddleAxis(verticalDirection: VerticalDirection.topToBottom);
      return true;
    }

    // 7 > 1
    // 8 > 2
    else if ((row1 == 3 && col1 == 0 && row2 == 0 && col2 == 0) ||
        (row1 == 3 && col1 == 1 && row2 == 0 && col2 == 1)) {
      foldAroundMiddleAxis(verticalDirection: VerticalDirection.bottomToTop);
      return true;
    }

    // 1 > 2
    // 3 > 4
    // 5 > 6
    // 7 > 8
    else if ((row1 == 0 && col1 == 0 && row2 == 0 && col2 == 1) ||
        (row1 == 1 && col1 == 0 && row2 == 1 && col2 == 1) ||
        (row1 == 2 && col1 == 0 && row2 == 2 && col2 == 1) ||
        (row1 == 3 && col1 == 0 && row2 == 3 && col2 == 1)) {
      foldAroundMiddleAxis(horizontalDirection: HorizontalDirection.leftToRight);
      return true;
    }

    // 2 > 1
    // 4 > 3
    // 6 > 5
    // 8 > 7
    else if ((row1 == 0 && col1 == 1 && row2 == 0 && col2 == 0) ||
        (row1 == 1 && col1 == 1 && row2 == 1 && col2 == 0) ||
        (row1 == 2 && col1 == 1 && row2 == 2 && col2 == 0) ||
        (row1 == 3 && col1 == 1 && row2 == 3 && col2 == 0)) {
      foldAroundMiddleAxis(horizontalDirection: HorizontalDirection.rightToLeft);
      return true;

    }

    return false;
  }

  List<List<Segment>> segmentGrid(){
    final allSegments = [
      row0Left,
      row0Right,
      row1Left,
      row1Right,
      row2Left,
      row2Right,
      row3Left,
      row3Right,
    ];

    return allSegments;
  }

  void reverseReload() {
    final allSegments = [
      row0Left,
      row0Right,
      row1Left,
      row1Right,
      row2Left,
      row2Right,
      row3Left,
      row3Right,
    ];

    for (int i = 0; i < allSegments.length; i++) {
      List<Segment> reversed = allSegments[i].reversed.map((segment) {
        return segment.copyWith(
          frontImage: segment.backImage,
          backImage: segment.frontImage,
        );
      }).toList();

      allSegments[i]
        ..clear()
        ..addAll(reversed);
    }
  }

}