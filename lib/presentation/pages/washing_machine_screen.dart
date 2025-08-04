import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/roster_controller.dart';
import 'clothing_game_screen.dart';

class WashingMachineScreen extends StatefulWidget {
  const WashingMachineScreen({super.key});

  @override
  _WashingMachineScreenState createState() => _WashingMachineScreenState();
}

class _WashingMachineScreenState extends State<WashingMachineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showShirt = false;
  bool _hideWashingMachine = false;
  final Random _random = Random();

  final RosterController controller = Get.find();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      _showShirt = true;
    });
    _controller.forward().then((_) {
      setState(() {
        _hideWashingMachine = true;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClothingGameScreen(),
          ),
        );
      });
    });
  }

  List<Widget> _generateBubbles(double width, double height) {
    return List.generate(20, (index) {
      double size = _random.nextDouble() * 40.w + 20.w;
      double startX = _random.nextDouble() * width;
      double startY = _random.nextDouble() * height;
      double bubbleSpeed = _random.nextDouble() * 5 + 2;

      return AnimatedPositioned(
        duration: Duration(seconds: bubbleSpeed.toInt()),
        left: startX + _random.nextDouble() * 50.w - 25.w,
        top: startY + _random.nextDouble() * 50.h - 25.h,
        child: Opacity(
          opacity: _random.nextDouble(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.6),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBackground() {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow[100]!, Colors.yellow[200]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._generateBubbles(1.sw, 1.sh),
          Positioned(
            top: 50.h,
            left: 100.w,
            child: AnimatedOpacity(
              opacity: 0.3,
              duration: Duration(seconds: 3),
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        alignment: Alignment.center,
        children: [
          _buildBackground(),
          if (!_hideWashingMachine)
            Center(
              child: GestureDetector(
                onTap: _startAnimation,
                child: AnimatedOpacity(
                  opacity: _hideWashingMachine ? 0 : 1,
                  duration: Duration(milliseconds: 500),
                  child: Image.asset(
                    'assets/images/washing_machine.png',
                    width: 0.8.sw,
                  ),
                ),
              ),
            ),
          if (_showShirt)
            Center(
              child: ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  controller.selectedStage.value!.frontImagePath,
                  width: 0.9.sw,
                  height: 0.7.sh,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
