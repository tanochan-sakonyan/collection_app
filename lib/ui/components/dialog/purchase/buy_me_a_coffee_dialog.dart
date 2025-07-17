import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class BuyMeACoffeeDialog extends StatefulWidget {
  const BuyMeACoffeeDialog({
    super.key,
    // required this.product, // ← ProductDetails は外で取得して渡す
  });

  // final ProductDetails product;

  @override
  State<BuyMeACoffeeDialog> createState() => _BuyMeACoffeeDialogState();
}

class _BuyMeACoffeeDialogState extends State<BuyMeACoffeeDialog> {
  final _iap = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _sub;
  bool _isBuying = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // 購入結果を監視
    _sub = _iap.purchaseStream.listen(_onPurchase, onDone: () => _sub.cancel());
  }

  // ─────────────────────────────────────
  // 購入ストリーム
  // ─────────────────────────────────────
  void _onPurchase(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      // if (p.productID != widget.product.id) continue; // 他商品は無視

      if (p.status == PurchaseStatus.purchased) {
        // 消耗型: 特にローカル保存は不要。購入成功を UI で伝えるのみ
        if (p.pendingCompletePurchase) {
          await _iap.completePurchase(p); // ★変更: 必ず finish する
        }
        setState(() {
          _isBuying = false;
          _done = true;
        });
      } else if (p.status == PurchaseStatus.error) {
        setState(() => _isBuying = false);
        _showSnack('購入エラー: ${p.error}');
      }
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────
  // 購入処理（Consumable 版）
  // ─────────────────────────────────────
  Future<void> _buy() async {
    setState(() => _isBuying = true);

    // final param = PurchaseParam(productDetails: widget.product);

    // ★変更: buyNonConsumable → buyConsumable
    // await _iap.buyConsumable(
    // purchaseParam: param,
    // autoConsume: true, // iOS では無視されるが Android で自動消費
    // );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ─────────────────────────────────────
  // UI
  // ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.local_cafe_rounded, size: 28),
          SizedBox(width: 8),
          Text('Buy me a coffee ☕'),
        ],
      ),
      content: _done
          ? const Text('ご支援ありがとうございます！🥳')
          : const Text(
              'アプリがお役に立ったら\n'
              'コーヒー１杯ぶんのご支援をお願いします！\n\n'
              '開発の励みになります😊',
            ),
      actions: _done
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ]
          : [
              TextButton(
                onPressed: _isBuying ? null : () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              FilledButton.tonal(
                onPressed: _isBuying ? null : _buy,
                child: _isBuying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('コーヒーを奢る'),
                //  (${widget.product.price})
              ),
            ],
    );
  }
}
