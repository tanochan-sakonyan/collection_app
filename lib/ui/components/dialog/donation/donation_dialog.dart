import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:mr_collection/ui/components/dialog/donation/donation_thanks_dialog.dart';

class _DonationOption {
  const _DonationOption({
    required this.productId,
    required this.assetPath,
    required this.name,
    required this.priceLabel,
    required this.assetWidth,
  });

  final String productId;
  final String assetPath;
  final String name;
  final String priceLabel;
  final double assetWidth;
}

const List<_DonationOption> _donationOptions = [
  _DonationOption(
    productId: 'app.web.mrCollection.coffee.tip.small',
    assetPath: 'assets/icons/ic_coffee.svg',
    name: 'カフェモカ',
    priceLabel: '120円',
    assetWidth: 48,
  ),
  _DonationOption(
    productId: 'app.web.mrCollection.coffee.tip.medium',
    assetPath: 'assets/icons/ic_frappe.svg',
    name: '抹茶フラッペ',
    priceLabel: '550円',
    assetWidth: 52,
  ),
  _DonationOption(
    productId: 'app.web.mrCollection.coffee.tip.large',
    assetPath: 'assets/icons/ic_sweets.svg',
    name: 'スイーツセット',
    priceLabel: '1200円',
    assetWidth: 58,
  ),
];

Set<String> get _donationProductIds =>
    _donationOptions.map((option) => option.productId).toSet();

class DonationDialog extends ConsumerStatefulWidget {
  const DonationDialog({super.key});
  @override
  DonationDialogState createState() => DonationDialogState();
}

class DonationDialogState extends ConsumerState<DonationDialog> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final Map<String, ProductDetails> _products = {};
  bool _isStoreAvailable = false;
  bool _isLoadingProducts = true;
  String? _processingProductId;

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

  Future<void> _initializeStore() async {
    debugPrint('[IAP] _initializeStore start');
    try {
      final available = await _inAppPurchase.isAvailable();
      debugPrint('[IAP] isAvailable -> $available mounted=$mounted');
      if (!mounted) return;
      if (!available) {
        setState(() {
          _isStoreAvailable = false;
          _isLoadingProducts = false;
        });
        debugPrint('[IAP] Store not available');
        _reportIssue('In-app purchase store not available.');
        return;
      }

      debugPrint('[IAP] Subscribing to purchaseStream');
      _purchaseSubscription ??= _inAppPurchase.purchaseStream
          .listen(_handlePurchaseUpdates,
              onError: (Object error, StackTrace stackTrace) {
        debugPrint('[IAP] purchaseStream onError: $error');
        _reportIssue(
          'Purchase stream error: $error',
          userMessage: '購入処理でエラーが発生しました。',
        );
        if (mounted) {
          setState(() => _processingProductId = null);
        }
      });

      final response =
          await _inAppPurchase.queryProductDetails(_donationProductIds);
      debugPrint(
          '[IAP] queryProductDetails requested for: ${_donationProductIds.toList()}');

      if (!mounted) return;

      if (response.error != null) {
        debugPrint('[IAP] queryProductDetails error: ${response.error}');
        _reportIssue('Product query error: ${response.error}');
        setState(() {
          _isStoreAvailable = false;
          _isLoadingProducts = false;
        });
        return;
      }

      setState(() {
        _products.clear();
        _products.addEntries(
          response.productDetails
              .map((product) => MapEntry(product.id, product)),
        );
        _isStoreAvailable = true;
        _isLoadingProducts = false;
      });
      debugPrint(
          '[IAP] queryProductDetails success. products=${_products.keys.toList()} notFound=${response.notFoundIDs}');

      if (response.notFoundIDs.isNotEmpty) {
        _reportIssue('Not found product ids: ${response.notFoundIDs}');
      }
      debugPrint('[IAP] _initializeStore done');
    } catch (e, stackTrace) {
      debugPrint('[IAP] _initializeStore exception: $e\n$stackTrace');
      _reportIssue('Failed to initialize in-app purchases: $e\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _isStoreAvailable = false;
        _isLoadingProducts = false;
        _processingProductId = null;
      });
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    debugPrint(
        '[IAP] _handlePurchaseUpdates called. count=${purchases.length} mounted=$mounted');
    for (final purchase in purchases) {
      final pid = purchase.productID;
      final inTarget = _donationProductIds.contains(pid);
      debugPrint(
          '[IAP] purchase: id=$pid status=${purchase.status} pending=${purchase.pendingCompletePurchase} inTarget=$inTarget error=${purchase.error?.message} code=${purchase.error?.code}');

      if (!inTarget) {
        debugPrint('[IAP] Skip non-donation product: $pid');
        continue;
      }

      final isCurrent = _processingProductId == pid;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
          debugPrint('[IAP] status=purchased -> show thanks');
          _showThanksDialogForProduct(pid);
          break;

        case PurchaseStatus.restored:
          if (isCurrent) {
            debugPrint(
                '[IAP] status=restored for current pid -> treat as success and show thanks');
            _showThanksDialogForProduct(pid);
          } else {
            debugPrint(
                '[IAP] status=restored for NON-current pid -> skip (likely historical restore)');
          }
          break;

        case PurchaseStatus.error:
          debugPrint('[IAP] status=error -> report');
          _reportIssue(
            'Purchase error for $pid: ${purchase.error}',
            userMessage: '購入がキャンセルまたは失敗しました。',
          );
          break;

        case PurchaseStatus.pending:
          debugPrint('[IAP] status=pending');
          break;

        default:
          debugPrint('[IAP] status=${purchase.status} (unhandled)');
          break;
      }

      if (purchase.pendingCompletePurchase) {
        try {
          debugPrint('[IAP] Completing purchase for $pid');
          await _inAppPurchase.completePurchase(purchase);
        } catch (e, st) {
          debugPrint('[IAP] completePurchase failed: $e\n$st');
        }
      }

      if (mounted && _processingProductId == pid) {
        debugPrint('[IAP] Clear processing flag for $pid');
        setState(() => _processingProductId = null);
      }
    }
  }

  Future<void> _startPurchase(String productId) async {
    debugPrint(
        '[IAP] _startPurchase called for $productId processing=$_processingProductId isStoreAvailable=$_isStoreAvailable');
    if (_processingProductId != null) {
      debugPrint('[IAP] Another purchase is in progress.');
      return;
    }

    if (!_isStoreAvailable) {
      debugPrint('[IAP] Attempted purchase while store unavailable');
      _reportIssue(
        'Attempted purchase while store unavailable.',
        userMessage: '現在購入を利用できません。',
      );
      return;
    }

    final product = _products[productId];
    debugPrint(
        '[IAP] Resolved product: ${product?.id} price=${product?.price}');
    if (product == null) {
      _reportIssue(
        'Product details missing for productId=$productId',
        userMessage: '商品情報が見つかりませんでした。',
      );
      return;
    }

    setState(() => _processingProductId = productId);

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      debugPrint(
          '[IAP] Calling buyConsumable(autoConsume=true) for $productId');
      final success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      debugPrint('[IAP] buyConsumable returned: $success');

      if (!success && mounted) {
        setState(() => _processingProductId = null);
        _reportIssue(
          'buyConsumable returned false for productId=$productId',
          userMessage: '購入処理を開始できませんでした。',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
          '[IAP] Exception in _startPurchase($productId): $e\n$stackTrace');
      _reportIssue(
        'Failed to start purchase for productId=$productId: $e\n$stackTrace',
        userMessage: '購入に失敗しました。',
      );
      if (mounted) {
        setState(() => _processingProductId = null);
      }
    }
  }

  void _showThanksDialogForProduct(String productId) {
    // Entry log
    debugPrint(
        '[Donation] _showThanksDialogForProduct called. productId=$productId mounted=$mounted');

    if (!mounted) {
      debugPrint('[Donation] Aborted: widget not mounted.');
      return;
    }

    // Map productId -> dialog with detailed logging
    DonationThanksDialog? dialog;
    switch (productId) {
      case 'app.web.mrCollection.coffee.tip.small':
        debugPrint('[Donation] Dialog mapping: SMALL');
        dialog = const DonationThanksDialog(
          title: 'ご支援ありがとうございます！',
          messageLines: [
            'ごちそうさまです！',
            'カフェモカでほっと一息ついて、',
            'また開発がんばります！',
            '応援してくれてありがとう🙌',
          ],
          assetPath: 'assets/icons/ic_coffee.svg',
          assetWidth: 120,
        );
        break;
      case 'app.web.mrCollection.coffee.tip.medium':
        debugPrint('[Donation] Dialog mapping: MEDIUM');
        dialog = const DonationThanksDialog(
          title: 'ご支援ありがとうございます！',
          messageLines: [
            'ごちそうさまです！',
            '抹茶フラッペでリフレッシュして、',
            '次のアイデアにつなげます！',
            '応援してくれてありがとう🙌',
          ],
          assetPath: 'assets/icons/ic_frappe.svg',
          assetWidth: 120,
        );
        break;
      case 'app.web.mrCollection.coffee.tip.large':
        debugPrint('[Donation] Dialog mapping: LARGE');
        dialog = const DonationThanksDialog(
          title: 'ご支援ありがとうございます！',
          messageLines: [
            'ごちそうさまです！',
            'ドーナツで当分補給ばっちり！',
            '集中モードに入ります！',
            '応援してくれてありがとう🙌',
          ],
          assetPath: 'assets/icons/ic_sweets.svg',
          assetWidth: 120,
        );
        break;
      default:
        debugPrint(
            '[Donation] No dialog mapping found for productId=$productId');
        _reportIssue('No thanks dialog mapped for productId=$productId');
        return;
    }

    // Context / Navigator diagnostics
    final ctx = context;
    final nav = Navigator.maybeOf(ctx);
    final rootNav = Navigator.maybeOf(ctx, rootNavigator: true);
    debugPrint(
        '[Donation] Context info: context.hash=${ctx.hashCode} hasNavigator=${nav != null} hasRootNavigator=${rootNav != null}');

    // Schedule microtask + post-frame to avoid build-time showDialog
    scheduleMicrotask(() {
      debugPrint(
          '[Donation] Microtask queued before showing dialog for productId=$productId');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        debugPrint('[Donation] PostFrame: widget unmounted. Skip showDialog.');
        return;
      }
      try {
        debugPrint(
            '[Donation] Attempting to show ThanksDialog (useRootNavigator=true).');
        showDialog<void>(
          context: ctx,
          useRootNavigator: true,
          barrierDismissible: true,
          builder: (dialogCtx) {
            debugPrint(
                '[Donation] Dialog builder invoked. dialogCtx.hash=${dialogCtx.hashCode}');
            return dialog!;
          },
        ).then((_) {
          debugPrint('[Donation] ThanksDialog closed for productId=$productId');
        }).catchError((e, st) {
          debugPrint('[Donation] showDialog Future error: $e\n$st');
        });
      } catch (e, st) {
        debugPrint('[Donation] Exception while calling showDialog: $e\n$st');
        _showSnackBar('サンクスダイアログの表示に失敗しました。');
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  void _reportIssue(String debugMessage, {String? userMessage}) {
    debugPrint(debugMessage);
    if (userMessage != null) {
      _showSnackBar(userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          width: 320,
          height: 310,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              Text(
                "開発者にドリンク１杯をご馳走する",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 14),
              Builder(
                builder: (context) {
                  final baseStyle = GoogleFonts.notoSansJp(
                    fontSize: 11,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w600,
                  );
                  return Text.rich(
                    TextSpan(
                      style: baseStyle,
                      children: [
                        const TextSpan(
                          text: "「集金くん」は学生エンジニアによって\n",
                        ),
                        TextSpan(
                          text: "赤字",
                          style:
                              baseStyle.copyWith(color: const Color(0xFFE53935)),
                        ),
                        const TextSpan(
                          text:
                              "開発されています。\nよりよい機能を継続的に届けられるよう、\nご支援いただけると幸いです。",
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildDonationRowChildren(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDonationRowChildren() {
    final widgets = <Widget>[];
    for (var i = 0; i < _donationOptions.length; i++) {
      final option = _donationOptions[i];
      widgets.add(_DonationCard(
        option: option,
        onTap: () => _startPurchase(option.productId),
        enabled: _isStoreAvailable && !_isLoadingProducts,
        processing: _processingProductId == option.productId,
      ));
      if (i < _donationOptions.length - 1) {
        widgets.add(const SizedBox(width: 6));
      }
    }
    return widgets;
  }
}

class _DonationCard extends StatelessWidget {
  const _DonationCard({
    required this.option,
    required this.onTap,
    required this.enabled,
    required this.processing,
  });

  final _DonationOption option;
  final VoidCallback onTap;
  final bool enabled;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !processing;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1 : 0.5,
        child: Container(
          width: 84,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(option.assetPath, width: option.assetWidth),
              const SizedBox(height: 4),
              Text(
                option.name,
                style: GoogleFonts.notoSansJp(fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                option.priceLabel,
                style: GoogleFonts.notoSansJp(
                  fontSize: 10,
                  color: const Color(0xFF006956),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
