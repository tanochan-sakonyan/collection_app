import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mr_collection/provider/ads_removal_provider.dart';
import 'package:mr_collection/ui/components/dialog/ads/remove_ads_thanks_dialog.dart';

class RemoveAdsDialog extends ConsumerStatefulWidget {
  const RemoveAdsDialog({super.key});

  @override
  // ダイアログの状態を管理する。
  ConsumerState<RemoveAdsDialog> createState() => RemoveAdsDialogState();
}

class RemoveAdsDialogState extends ConsumerState<RemoveAdsDialog> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _product;
  bool _isStoreAvailable = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  Completer<bool>? _restoreCompleter;

  @override
  void initState() {
    super.initState();
    _initializeStore();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  // ストア情報と商品情報を初期化する。
  Future<void> _initializeStore() async {
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!mounted) return;
      if (!available) {
        setState(() {
          _isStoreAvailable = false;
          _isLoading = false;
        });
        _showSnackBar('現在購入を利用できません。');
        return;
      }

      _purchaseSubscription ??= _inAppPurchase.purchaseStream
          .listen(_handlePurchaseUpdates, onError: (Object error) {
        _showSnackBar('購入処理でエラーが発生しました。');
      });

      final response =
          await _inAppPurchase.queryProductDetails({adsRemovalProductId});
      if (!mounted) return;

      if (response.error != null) {
        _showSnackBar('商品情報の取得に失敗しました。');
        setState(() {
          _isStoreAvailable = false;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _product = response.productDetails.isNotEmpty
            ? response.productDetails.first
            : null;
        _isStoreAvailable = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStoreAvailable = false;
        _isLoading = false;
      });
      _showSnackBar('購入の準備に失敗しました。');
    }
  }

  // 購入状態の更新を処理する。
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != adsRemovalProductId) {
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        unawaited(ref.read(adsRemovalProvider.notifier).setAdsRemoved(true));
        _restoreCompleter?.complete(true);
        _showThanksDialog();
      } else if (purchase.status == PurchaseStatus.error) {
        _showSnackBar('購入がキャンセルまたは失敗しました。');
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await _inAppPurchase.completePurchase(purchase);
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  // 購入処理を開始する。
  Future<void> _startPurchase() async {
    if (_isProcessing) return;
    if (!_isStoreAvailable) {
      _showSnackBar('現在購入を利用できません。');
      return;
    }
    if (_product == null) {
      _showSnackBar('商品情報が見つかりませんでした。');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final purchaseParam = PurchaseParam(productDetails: _product!);
      final success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success && mounted) {
        setState(() => _isProcessing = false);
        _showSnackBar('購入処理を開始できませんでした。');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSnackBar('購入に失敗しました。');
    }
  }

  // 購入復元を実行する。
  Future<void> _restorePurchase() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    _restoreCompleter = Completer<bool>();
    try {
      await _inAppPurchase.restorePurchases();
    } catch (_) {
      _restoreCompleter = null;
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSnackBar('購入の復元に失敗しました。');
      return;
    }

    // 結果を _handlePurchaseUpdates から受け取る (最大3秒)
    final restored = await _restoreCompleter!.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () => false,
    );
    _restoreCompleter = null;

    if (!mounted) return;
    // 成功時は _handlePurchaseUpdates が _showThanksDialog() を呼ぶ
    if (!restored) {
      setState(() => _isProcessing = false);
      _showSnackBar('復元できる購入が見つかりませんでした。');
    }
  }

  // ありがとうダイアログを表示する。
  void _showThanksDialog() {
    if (!mounted) return;
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    rootNavigator.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: rootNavigator.context,
        builder: (_) => const RemoveAdsThanksDialog(),
      );
    });
  }

  // スナックバーで通知する。
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF37F3BE), Color(0xFF6BE8F0)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル行（アイコン + テキスト）
              Row(
                children: [
                  const Icon(
                    Symbols.block,
                    color: Colors.black,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '広告を削除する',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 説明テキスト
              Text(
                '全ての広告を永久に削除します。\n※ 金額設定で端数切り上げをすればすぐ元が取れます。',
                style: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // 価格と購入ボタンを横並び
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥300 買い切り',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 60),
                  _isLoading
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: _isProcessing || _isLoading
                              ? null
                              : _startPurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          child: Text(
                            '購入',
                            style: GoogleFonts.notoSansJp(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 12),
              // 購入を復元する
              Center(
                child: GestureDetector(
                  onTap: _isProcessing ? null : _restorePurchase,
                  child: Text(
                    '購入を復元する',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
