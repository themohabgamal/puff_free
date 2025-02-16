import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final List<String> _productIds = [
    'weekly_plan',
    'monthly_plan',
    'lifetime_plan'
  ];
  List<ProductDetails> _products = [];
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initializePayment() async {
    _subscription = _inAppPurchase.purchaseStream.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      setState(() {
        _errorMessage = 'Error listening to purchase updates: $error';
        _loading = false;
      });
    });

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      setState(() {
        _errorMessage = 'In-app purchase is not available on this device.';
        _loading = false;
      });
      return;
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds.toSet());
    if (response.error != null) {
      setState(() {
        _errorMessage =
            'Failed to fetch product details: ${response.error!.message}';
        _loading = false;
      });
      return;
    }

    if (response.productDetails.isEmpty) {
      setState(() {
        _errorMessage = 'No products available.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _deliverProduct(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Purchase failed: ${purchase.error?.message}')),
        );
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${purchase.productID} purchase successful!')),
    );
    _inAppPurchase.completePurchase(purchase);
  }

  void _buyProduct(String productId) async {
    final product = _products.firstWhere((p) => p.id == productId);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Your Plan'),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      ..._products
                          .map((product) => _buildPlanOption(context, product)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'Get access to exclusive features by upgrading your plan.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontFamily: 'Nunito',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanOption(BuildContext context, ProductDetails product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.blue, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                product.price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _buyProduct(product.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),
            child: Text('Choose ${product.title}'),
          ),
        ],
      ),
    );
  }
}
