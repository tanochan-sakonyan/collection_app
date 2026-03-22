import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// オンボーディング完了済みかどうかのSharedPreferencesキー
const String onboardingCompletedKey = 'onboarding_completed';

/// オンボーディングの総ページ数
const int _totalPages = 5;

/// オンボーディング画面
class OnboardingScreen extends StatefulWidget {
  /// オンボーディング完了時のコールバック
  final VoidCallback onCompleted;

  const OnboardingScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

  /// オンボーディングが未完了かどうかを判定
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(onboardingCompletedKey) ?? false);
  }

  /// オンボーディング完了フラグを保存
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
  }
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 完了処理
  Future<void> _complete() async {
    await OnboardingScreen.markCompleted();
    widget.onCompleted();
  }

  /// 次のページへ進む
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // 波アニメーション（背景装飾）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavePainter(
                    animationValue: _waveController.value,
                    color: Colors.white,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          // メインコンテンツ
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalPages,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Text(
                          '${index + 1}ページ目です',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _totalPages,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _currentPage == _totalPages - 1
                              ? _complete
                              : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            _currentPage == _totalPages - 1 ? 'はじめる' : '次へ',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 水面のように揺れる波を3層に重ねて描画するペインター
class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animationValue * 2 * pi;

    // 3層の波を異なる速度・振幅・透明度で描画
    _drawWave(
      canvas,
      size,
      amplitude: 14,
      frequency: 1.0,
      phase: phase,
      verticalOffset: size.height * 0.55,
      opacity: 0.18,
    );
    _drawWave(
      canvas,
      size,
      amplitude: 10,
      frequency: 2.0,
      phase: phase * 2 + 1.0,
      verticalOffset: size.height * 0.65,
      opacity: 0.14,
    );
    _drawWave(
      canvas,
      size,
      amplitude: 8,
      frequency: 3.0,
      phase: phase * 3 + 2.5,
      verticalOffset: size.height * 0.75,
      opacity: 0.10,
    );
  }

  /// 波の曲線を描画
  void _drawWave(
    Canvas canvas,
    Size size, {
    required double amplitude,
    required double frequency,
    required double phase,
    required double verticalOffset,
    required double opacity,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y = verticalOffset +
          amplitude * sin(frequency * (x / size.width) * 2 * pi + phase) +
          amplitude * 0.5 * sin(frequency * 2 * (x / size.width) * 2 * pi + phase * 1.5);
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
