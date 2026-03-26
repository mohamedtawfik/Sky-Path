import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../game/levels_data.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  bool _premiumUnlocked = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Callbacks
  Function(bool)? onPurchaseStatusChanged;
  Function(String)? onError;

  bool get isPremiumUnlocked => _premiumUnlocked;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        FirebaseCrashlytics.instance.log('In-App Purchases not available');
        return;
      }

      // Listen for purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) {
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            reason: 'IAP stream error',
          );
          onError?.call('Purchase error occurred');
        },
      );

      // Load products
      await _loadProducts();

      // Restore purchases
      await restorePurchases();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'Failed to initialize IAP');
    }
  }

  Future<void> _loadProducts() async {
    const Set<String> productIds = {LevelsData.premiumProductId};

    final ProductDetailsResponse response =
        await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      FirebaseCrashlytics.instance.log(
          'Error loading products: ${response.error!.message}');
    }

    if (response.notFoundIDs.isNotEmpty) {
      FirebaseCrashlytics.instance.log(
          'Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // Show loading or pending state
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          FirebaseCrashlytics.instance.log(
              'Purchase error: ${purchaseDetails.error?.message}');
          onError?.call(purchaseDetails.error?.message ?? 'Purchase failed');
          break;
        case PurchaseStatus.canceled:
          // User cancelled
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == LevelsData.premiumProductId) {
      _premiumUnlocked = true;
      onPurchaseStatusChanged?.call(true);
      FirebaseCrashlytics.instance.log('Premium levels purchased successfully');
    }
  }

  Future<void> purchasePremium() async {
    if (!_available) {
      onError?.call('In-App Purchases not available on this device');
      return;
    }

    if (_products.isEmpty) {
      onError?.call('Product not available. Please try again later.');
      return;
    }

    try {
      final ProductDetails product = _products.firstWhere(
        (p) => p.id == LevelsData.premiumProductId,
      );

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);

      // Non-consumable purchase (one-time unlock)
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'Failed to initiate purchase');
      onError?.call('Failed to start purchase. Please try again.');
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'Failed to restore purchases');
    }
  }

  /// For development/testing: manually set premium status
  void setPremiumForTesting(bool value) {
    _premiumUnlocked = value;
    onPurchaseStatusChanged?.call(value);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
