import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mr_collection/ui/components/dialog/ads/remove_ads_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// オンボーディング完了済みかどうかのSharedPreferencesキー
const String onboardingCompletedKey = 'onboarding_completed';

/// オンボーディングの総ページ数
const int _totalPages = 7;

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
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  // ウェルカムページ用アニメーション
  late final AnimationController _welcomeController;
  late final Animation<double> _welcomeTextOpacity;
  late final Animation<Offset> _welcomeTextSlide;

  // 最終ページ用アニメーション
  late final AnimationController _startPageController;
  late final Animation<double> _titleScale;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    // アイコンのふわふわアニメーションコントローラー
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    // ウェルカムテキストのアニメーション
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _welcomeTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _welcomeTextSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    // 最終ページ用アニメーションコントローラー
    _startPageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _titleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _startPageController,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _startPageController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _startPageController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _floatController.dispose();
    _welcomeController.dispose();
    _startPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 1ページ目のウェルカムページを構築
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // ふわふわ浮くアイコン
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/icons/icon.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          // ウェルカムテキスト（フェードイン+スライドイン）
          AnimatedBuilder(
            animation: _welcomeController,
            builder: (context, child) {
              return SlideTransition(
                position: _welcomeTextSlide,
                child: Opacity(
                  opacity: _welcomeTextOpacity.value,
                  child: child,
                ),
              );
            },
            child: const Text(
              'ようこそ\n集金くんへ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Noto Sans JP',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2ページ目：LINEグループからイベント追加の説明ページ
  Widget _buildLineGroupPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 160),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.05, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 74),
              // ページタイトル
              Center(
                child: const Text(
                  'イベントを追加する',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Noto Sans JP',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // イベント追加方法の概要セクション
              _buildSectionCard(
                children: [
                  _buildTutorialImage('assets/images/tutorial_2_0.png'),
                  _buildStepItem(
                      1, 'LINEグループからイベントを作成できます。\nたくさんいるメンバーも自動で追加できて便利です。'),
                  _buildStepItem(2,
                      '他のイベントからメンバーを引き継げます。\n二次会みたいに、同じメンバーや似たメンバーで再度集金することになった場合に便利です。'),
                  _buildStepItem(3, '手動でイベントを作成します。'),
                ],
              ),
              const SizedBox(height: 12),
              // LINEグループからの追加手順セクション
              _buildSectionCard(
                children: [
                  const Text(
                    'LINEグループからイベントを追加',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(1, '公式LINEをLINEグループに\nメンバーとして追加します'),
                  _buildTutorialImage('assets/images/tutorial_2_1.PNG'),
                  _buildStepItem(2, '集金くんを再起動します'),
                  _buildStepItem(3, 'イベント追加ボタンから\n「LINEグループで追加」を選択します'),
                  _buildTutorialImage('assets/images/tutorial_2_2.PNG'),
                  _buildStepItem(4, '取得したLINEグループが\n表示されます'),
                  _buildTutorialImage('assets/images/tutorial_2_3.PNG'),
                ],
              ),
              const SizedBox(height: 12),
              // 注意事項セクション
              _buildSectionCard(
                children: [
                  const Text(
                    '※ 注意点',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appleでログインを使用して集金くんにログインしている場合、'
                    'LINEグループ情報は取得できません。\n'
                    '一度ログアウトしたのち、LINEでログインして再度お試しください。',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  _buildTutorialImage('assets/images/tutorial_2_4.PNG'),
                ],
              ),
              const SizedBox(height: 12),
              // よくある質問セクション
              _buildSectionCard(
                children: [
                  const Text(
                    'よくある質問',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    'グループに追加したのに取得できません',
                    '一度公式LINEを退会させたのち、もう一度お試しください。'
                        'それでも解決しない場合、お手数ですが手動追加をご利用の上、'
                        '問題があった旨を公式LINEのチャットにてお知らせください。',
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    'メンバーに、集金管理の情報は伝わりますか？',
                    '伝わりません。伝わるのは、集金くん公式LINEが'
                        'グループに追加されたという情報だけです。',
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    '追加した瞬間退会してしまいます',
                    'LINEグループには1つの公式LINEしか追加できないため、'
                        'もし別の公式LINEがいる場合はそのアカウントを退会させる'
                        '必要があります。グループの利用状況に応じて判断をお願いします。',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3ページ目：メンバー追加の説明ページ
  Widget _buildAddMemberPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 160),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.05, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 74),
              // ページタイトル
              const Center(
                child: Text(
                  'メンバーを追加',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Noto Sans JP',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // メンバー追加方法セクション
              _buildSectionCard(
                children: [
                  const Text(
                    'メンバーを追加',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '改行区切りでメンバーをまとめて追加できます。',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 2枚の画像を横並びで表示
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/tutorial_3_1.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/tutorial_3_2.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ステータスセクション
              _buildSectionCard(
                children: [
                  const Text(
                    'ステータス',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  _buildTutorialImage('assets/images/tutorial_3_4.png'),
                  _buildStepItem(1, '支払い済み：現金などでお金を受け取った場合に使用します'),
                  _buildStepItem(2, 'PayPayで支払い済み：PayPayでお金を受け取った場合に使用します'),
                  _buildStepItem(3, '未払い'),
                  _buildStepItem(4, '欠席'),
                ],
              ),
              const SizedBox(height: 12),
              // よくある質問セクション
              _buildSectionCard(
                children: [
                  const Text(
                    'よくある質問',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    'PayPayで支払った場合、ステータスが自動で反映されますか？',
                    'いいえ。PayPayの利用規約上、自動反映はできません。現金とPayPayを区別するための機能となります。',
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    '集金くんが支払い代行をしてくれるのですか？',
                    'いいえ。集金くんによる代行支払いはできません。グループの代表者がまとめて支払った後に、メンバーからお金を集める際の管理用アプリとなります。',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3枚の画像を横並びで表示
  Widget _buildTripleImages(String path1, String path2, String path3) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(path1, fit: BoxFit.fitWidth),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(path2, fit: BoxFit.fitWidth),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(path3, fit: BoxFit.fitWidth),
            ),
          ),
        ],
      ),
    );
  }

  /// 2枚の画像を横並びで表示
  Widget _buildDoubleImages(String path1, String path2) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(path1, fit: BoxFit.fitWidth),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(path2, fit: BoxFit.fitWidth),
            ),
          ),
        ],
      ),
    );
  }

  /// セクション内の説明テキスト
  Widget _buildDescText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Noto Sans JP',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.5,
      ),
    );
  }

  /// 4ページ目：金額設定の説明ページ
  Widget _buildAmountSettingPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 160),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.05, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 74),
              // ページタイトル
              const Center(
                child: Text(
                  '金額を設定する',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Noto Sans JP',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // グループ1：合計金額を入力する
              _buildSectionCard(
                children: [
                  const Text(
                    '合計金額を入力する',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  _buildTutorialImage('assets/images/tutorial_4_1.png'),
                  _buildDescText('合計金額を入力します。'),
                ],
              ),
              const SizedBox(height: 12),
              // グループ2：個別金額の設定
              _buildSectionCard(
                children: [
                  const Text(
                    '個別金額の設定',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDescText('個人が支払う金額を入力します'),
                  const SizedBox(height: 12),
                  _buildStepItem(1, '割り勘モード\n全員で均等に金額を割る場合に使用します。'),
                  _buildTutorialImage('assets/images/tutorial_4_2.png'),
                  _buildStepItem(2,
                      '金額の調整モード\n特定の人が多く金額を払う場合に使用します。\n例. 先輩や上司が多く払った。遅れて参加した人は少なく支払った。'),
                  _buildTutorialImage('assets/images/tutorial_4_3.png'),
                  _buildDescText(
                      '金額を入力し、ロックすることができます。ロックがかかっていない人たちで、残りの金額が割り勘されます。\n鍵マークをタップすることで、金額を固定&解除できます。'),
                  const SizedBox(height: 12),
                  _buildStepItem(3,
                      '役割別に調整モード\n役割によって支払う金額が異なる場合に使用します。\n例. 4年生は多く、1年生は少なく支払う。男性は多く、女性は少なく支払う。マネージャー以上は多く、新卒入社の人は少なく支払う。など'),
                  _buildTutorialImage('assets/images/tutorial_4_4.png'),
                  _buildDescText(
                      '「役割を入力する」ボタンから、役割と金額を入力し、メンバーに役割を割り振ります。\n役割が無い人で、残りの金額が割り勘されます。'),
                  _buildTripleImages(
                    'assets/images/tutorial_4_5.png',
                    'assets/images/tutorial_4_6.png',
                    'assets/images/tutorial_4_7.png',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // グループ3：端数切り上げモード
              _buildSectionCard(
                children: [
                  const Text(
                    '端数切り上げモード',
                    style: TextStyle(
                      fontFamily: 'Noto Sans JP',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDescText('現金で受け取る場合、端数が多いと小銭が発生して大変です。'),
                  _buildTripleImages(
                    'assets/images/tutorial_4_8.png',
                    'assets/images/tutorial_4_9.png',
                    'assets/images/tutorial_4_10.png',
                  ),
                  _buildDescText(
                      '10円、50円、100円単位で端数を切り上げて金額を設定することができます。\n金額の調整モードや、役割から調整モードに切り上げを適用することも可能です。（割り勘されたメンバーの金額に切り上げが適用されます。）'),
                  _buildDoubleImages(
                    'assets/images/tutorial_4_11.png',
                    'assets/images/tutorial_4_12.png',
                  ),
                  _buildDescText(
                      '切り上げるので、まとめて払った人が損をすることはありません。\n余ったお金は、代表会計を頑張ったごほうびで何かに使うか、集金くんアプリの開発者に寄付してくれたらうれしいです！'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5ページ目：ホーム画面の説明ページ
  Widget _buildHomeScreenPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 160),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.05, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 74),
              // ページタイトル
              const Center(
                child: Text(
                  'ホーム画面',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Noto Sans JP',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTutorialImage('assets/images/tutorial_5_1.png'),
              const SizedBox(height: 12),
              _buildSectionCard(
                children: [
                  _buildStepItem(1,
                      'メンバーリスト\n名前、役割、金額、ステータスが表示されます。右側の並び替えボタンを押して、メンバーを支払い状況順に並び替えることもできます。'),
                  _buildStepItem(2, 'イベント名\nここをタップすることで、イベントの名前を変更することができます。'),
                  _buildStepItem(3, 'イベント追加\nイベントを追加する際にタップします。'),
                  _buildStepItem(4, 'イベント削除\nタップすると、選択されているイベントが削除されます。'),
                  _buildStepItem(5,
                      '集金状況共有ボタン\n現在の集金状況を共有できます。\n名前付きモード、匿名モードを選ぶことができます。'),
                  _buildStepItem(6, 'ヘルプボタン\n使い方を確認することができます。'),
                  _buildStepItem(7, '一括編集\nメンバーのステータスの一括変更や、メンバーの一括削除ができます'),
                  _buildStepItem(8, '人数・金額\n押すと、金額を入力・変更することができます。'),
                  _buildStepItem(9, 'メモ欄'),
                  _buildStepItem(10,
                      '催促メッセージ送信\nグループに集金くん公式LINEから自動でメッセージを送信することができます。\n未払いの人に自分から催促するのが気まずい時に便利です。\nLINEグループからメンバーを取得したグループでしか送ることができません。そのグループを引き継いで作成したグループでも、送ることはできませんのでご了承ください。'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 6ページ目：お願いページ
  Widget _buildRequestPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'お願い',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Noto Sans JP',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          // 浮くアイコン画像
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/tutorial_6_1.png',
                  width: 320,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 購入するボタン
          SizedBox(
            width: 120,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const RemoveAdsDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                '購入する',
                style: TextStyle(
                  fontFamily: 'Noto Sans JP',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Noto Sans JP',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: '集金くんは、現在'),
                    TextSpan(
                      text: '赤字',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                        text: '開発されています。\n'
                            '今後集金くんの機能を継続して提供できない可能性がございます。\n\n'
                            '広告を削除できる機能を300円でご用意しております。ぜひ、ご利用いただければと思います。'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 7ページ目（最終ページ）：さあはじめよう
  Widget _buildStartPage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ポップなスケールアニメーションで出現
          AnimatedBuilder(
            animation: _titleScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _titleScale.value,
                child: child,
              );
            },
            child: const Text(
              'さあ\nはじめよう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Noto Sans JP',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // フェードイン+スライドインで出現
          AnimatedBuilder(
            animation: _startPageController,
            builder: (context, child) {
              return SlideTransition(
                position: _subtitleSlide,
                child: Opacity(
                  opacity: _subtitleOpacity.value,
                  child: child,
                ),
              );
            },
            child: Text(
              'ストレスのない集金ライフを',
              style: TextStyle(
                fontFamily: 'Noto Sans JP',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// セクションカードを構築
  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 手順アイテムを構築
  Widget _buildStepItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  fontFamily: 'Noto Sans JP',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Noto Sans JP',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FAQ項目を構築
  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q. $question',
          style: const TextStyle(
            fontFamily: 'Noto Sans JP',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A. $answer',
          style: TextStyle(
            fontFamily: 'Noto Sans JP',
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// チュートリアル画像を構築
  Widget _buildTutorialImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            assetPath,
            width: 200,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
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
          // メインコンテンツ（PageView）
          SafeArea(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                // 最終ページに到達したらアニメーション開始
                if (index == 6) {
                  _startPageController.forward(from: 0.0);
                }
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildWelcomePage();
                }
                if (index == 1) {
                  return _buildHomeScreenPage();
                }
                if (index == 2) {
                  return _buildLineGroupPage();
                }
                if (index == 3) {
                  return _buildAddMemberPage();
                }
                if (index == 4) {
                  return _buildAmountSettingPage();
                }
                if (index == 5) {
                  return _buildRequestPage();
                }
                if (index == 6) {
                  return _buildStartPage();
                }
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
          // 下部コントロール（インジケーター・ボタン・スキップ）
          Positioned(
            left: 0,
            right: 0,
            bottom: (_currentPage == 0 || _currentPage == 6) ? 48 : 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),
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
                        _currentPage == 0
                            ? 'チュートリアルを開始'
                            : _currentPage == _totalPages - 1
                                ? 'はじめる'
                                : '次へ',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  // スキップボタン
                  TextButton(
                    onPressed: _complete,
                    child: const Text(
                      'スキップ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
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
          amplitude *
              0.5 *
              sin(frequency * 2 * (x / size.width) * 2 * pi + phase * 1.5);
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
