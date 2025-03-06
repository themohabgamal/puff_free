import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'main.dart'; // Ensure HomeScreen is imported correctly

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  _PaywallPageState createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  String? _selectedPlan;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // Handle the case where in-app purchases are not available
      return;
    }

    const Set<String> kIds = {'basic_plan', 'standard_plan', 'premium_plan'};
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kIds);

    if (response.notFoundIDs.isNotEmpty) {
      // Handle the case where some products are not found
    }

    setState(() {
      _products = response.productDetails;
    });
  }

  Future<void> _buyProduct(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Your Plan'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildPlanOption('Basic Plan', '\$7.99/week',
                'Weekly access to basic features.', 'basic_plan'),
            _buildPlanOption('Standard Plan', '\$15.99/month',
                'Monthly access to all features.', 'standard_plan'),
            _buildPlanOption('Premium Plan', '\$25.99/lifetime',
                'Lifetime access to all features.', 'premium_plan'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedPlan != null
                  ? () {
                      final selectedProduct = _products
                          .firstWhere((product) => product.id == _selectedPlan);
                      _buyProduct(selectedProduct).then((_) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        );
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
              ),
              child: const Text('Choose Plan'),
            ),
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

  Widget _buildPlanOption(
      String title, String price, String description, String productId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = productId;
        });
      },
      child: Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: productId,
              groupValue: _selectedPlan,
              onChanged: (String? value) {
                setState(() {
                  _selectedPlan = value;
                });
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
