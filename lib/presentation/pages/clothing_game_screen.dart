import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:confetti/confetti.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/roster_controller.dart';
import '../../data/models/pattern_loader.dart';
import '../../data/models/segment.dart';
import '../../data/models/shirt_game.dart';
import '../../data/models/pants_game.dart';
import '../../data/models/stage_type.dart';

class ClothingGameScreen extends StatefulWidget {
  const ClothingGameScreen({super.key});

  @override
  State<ClothingGameScreen> createState() => _ClothingGameScreenState();
}

class _ClothingGameScreenState extends State<ClothingGameScreen> {
  late FlameGame _game;
  late ConfettiController _confettiController;
  final RosterController _rosterController = Get.find<RosterController>();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// هنا نخزن الأنماط المحمّلة من JSON
  List<List<List<List<Map<String, dynamic>>>>> _shirtPatterns = [];
  List<List<List<List<Map<String, dynamic>>>>> _pantsPatterns = [];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    // تحميل الأنماط بشكل متزامن
    Future.wait([
      PatternLoader.loadShirtPatterns(),
      PatternLoader.loadPantsPatterns(),
    ]).then((results) {
      setState(() {
        _shirtPatterns = results[0];
        _pantsPatterns = results[1];
      });
      _initGame();
    }).catchError((error) {
      debugPrint('Error loading patterns: $error');
    });
  }


  void _initGame() {
    switch (_rosterController.selectedStage.value!.type) {
      case StageType.shirt:
        _game = ShirtGame(
          onGridUpdate: (grid) {
            if (_shouldTriggerConfetti(grid)) {
              _confettiController.play();
              _playSuccessSound();
              _rosterController.incrementUserStage(
                _rosterController.selectedUser.value!.id,
                _rosterController.selectedStage.value!.id,
              );
              _navigateBackAfterDelay();
            }
          },
          frontImagePath: _rosterController.selectedStage.value!.frontImage,
          backImagePath: _rosterController.selectedStage.value!.backImage,
        );
        break;
      case StageType.pants:
        _game = PantsGame(
          onGridUpdate: (grid) {
            if (_shouldTriggerConfetti(grid)) {
              _confettiController.play();
              _playSuccessSound();
              _rosterController.incrementUserStage(
                _rosterController.selectedUser.value!.id,
                _rosterController.selectedStage.value!.id,
              );
              _navigateBackAfterDelay();
            }
          },
          frontImagePath: _rosterController.selectedStage.value!.frontImage,
          backImagePath: _rosterController.selectedStage.value!.backImage,
        );
        break;
      default:
        throw UnsupportedError('نوع الملابس غير مدعوم حالياً');
    }
    setState(() {});
  }

  void _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('audio/win.m4a'));
  }

  void _navigateBackAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  bool _shouldTriggerConfetti(List<List<List<Segment>>> grid) {
    switch (_rosterController.selectedStage.value!.type) {
      case StageType.shirt:
        return _checkShirtCompletion(grid);
      case StageType.pants:
        return _checkPantsCompletion(grid);
      default:
        return false;
    }
  }

  List<List<List<Map<String, dynamic>>>> serialize(
      List<List<List<Segment>>> g) {
    return g
        .map((row) => row
        .map((cell) => cell
        .map((s) => {
      'id': s.id,
      'fh': s.flippedHorizontal,
      'fv': s.flippedVertical,
      'pr': s.priority,
    })
        .toList())
        .toList())
        .toList();
  }

  bool _checkShirtCompletion(List<List<List<Segment>>> grid) {
    final serialized = serialize(grid);
    final eq = const DeepCollectionEquality();
    for (var pat in _shirtPatterns) {
      if (eq.equals(pat, serialized)) return true;
    }
    return false;
  }

  bool _checkPantsCompletion(List<List<List<Segment>>> grid) {
    final serialized = serialize(grid);
    final eq = const DeepCollectionEquality();
    for (var pat in _pantsPatterns) {
      if (eq.equals(pat, serialized)) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.indigo.shade600,
        elevation: 4,
        shadowColor: Colors.indigo.shade200,
      ),
      body: Stack(
        children: [
          GameWidget(game: _game),
          Positioned(
            bottom: 100.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () {
                if (_game is ShirtGame) {
                  (_game as ShirtGame).flipAll();
                } else if (_game is PantsGame) {
                  (_game as PantsGame).flipAll();
                }
              },
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade700, // لون الزر
                  shape: BoxShape.circle, // الشكل الدائري
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // الظل
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.flip,
                  size: 30.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ClothingGameScreen(),
                  ),
                );
              },
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.orange.shade500, // لون الزر
                  shape: BoxShape.circle, // الشكل الدائري
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // الظل
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.refresh,
                  size: 30.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () {
                if (_game is ShirtGame) {
                  (_game as ShirtGame).highlightAllSections(
                    const Duration(seconds: 1),
                  );
                } else if (_game is PantsGame) {
                  (_game as PantsGame).highlightAllSections(
                    const Duration(seconds: 1),
                  );
                }
              },
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.green.shade600, // لون الزر
                  shape: BoxShape.circle, // الشكل الدائري
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // الظل
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.grid_on_rounded,
                  size: 30.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () {
                if (_game is ShirtGame) {
                  (_game as ShirtGame).firstNonEmptySegment();
                } else if (_game is PantsGame) {
                  (_game as PantsGame).firstNonEmptySegment();
                }
              },
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.purple.shade500, // لون الزر
                  shape: BoxShape.circle, // الشكل الدائري
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // الظل
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tips_and_updates_rounded,
                  size: 30.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 200,
              emissionFrequency: 0.05,
              maxBlastForce: 40,
              minBlastForce: 30,
              gravity: 0.2,
              particleDrag: 0.06,
              colors: const [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.yellow
              ],
            ),
          ),
        ],
      ),
    );
  }
}