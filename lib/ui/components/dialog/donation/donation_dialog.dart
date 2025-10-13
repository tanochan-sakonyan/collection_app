import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:mr_collection/ui/components/dialog/donation/donation_thanks_large_dialog.dart';
import 'package:mr_collection/ui/components/dialog/donation/donation_thanks_medium_dialog.dart';
import 'package:mr_collection/ui/components/dialog/donation/donation_thanks_small_dialog.dart';

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
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!mounted) return;
      if (!available) {
        setState(() {
          _isStoreAvailable = false;
          _isLoadingProducts = false;
        });
        _reportIssue('In-app purchase store not available.');
        return;
      }

      _purchaseSubscription ??= _inAppPurchase.purchaseStream
          .listen(_handlePurchaseUpdates,
              onError: (Object error, StackTrace stackTrace) {
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

      if (!mounted) return;

      if (response.error != null) {
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

      if (response.notFoundIDs.isNotEmpty) {
        _reportIssue('Not found product ids: ${response.notFoundIDs}');
      }
    } catch (e, stackTrace) {
      _reportIssue('Failed to initialize in-app purchases: $e\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _isStoreAvailable = false;
        _isLoadingProducts = false;
        _processingProductId = null;
      });
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (!_donationProductIds.contains(purchase.productID)) {
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased) {
        _showThanksDialogForProduct(purchase.productID);
      } else if (purchase.status == PurchaseStatus.error) {
        _reportIssue(
          'Purchase error for ${purchase.productID}: ${purchase.error}',
          userMessage: '購入がキャンセルまたは失敗しました。',
        );
      }

      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }

      if (mounted && _processingProductId == purchase.productID) {
        setState(() => _processingProductId = null);
      }
    }
  }

  Future<void> _startPurchase(String productId) async {
    if (_processingProductId != null) {
      return;
    }

    if (!_isStoreAvailable) {
      _reportIssue(
        'Attempted purchase while store unavailable.',
        userMessage: '現在購入を利用できません。',
      );
      return;
    }

    final product = _products[productId];
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
      final success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!success && mounted) {
        setState(() => _processingProductId = null);
        _reportIssue(
          'buyConsumable returned false for productId=$productId',
          userMessage: '購入処理を開始できませんでした。',
        );
      }
    } catch (e, stackTrace) {
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
    if (!mounted) return;

    Widget? buildDialog() {
      switch (productId) {
        case 'app.web.mrCollection.coffee.tip.small':
          return const DonationThanksSmallDialog();
        case 'app.web.mrCollection.coffee.tip.medium':
          return const DonationThanksMediumDialog();
        case 'app.web.mrCollection.coffee.tip.large':
          return const DonationThanksLargeDialog();
        default:
          return null;
      }
    }

    final dialog = buildDialog();
    if (dialog == null) {
      _reportIssue('No thanks dialog mapped for productId=$productId');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        useRootNavigator: true,
        builder: (_) => dialog,
      );
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
              Text(
                "「集金くん」は学生エンジニアによって\n赤字開発されています。\nよりよい機能を継続的に届けられるよう、\nご支援いただけると幸いです。",
                style: GoogleFonts.notoSansJp(
                    fontSize: 11,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
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
        widgets.add(const SizedBox(width: 8));
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
          width: 90,
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
