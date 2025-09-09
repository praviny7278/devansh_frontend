
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: OrderItemListPage(
      orderNumber: null,
      orderPlacedDate: null,
    ),
  ));
}

class OrderItemListPage extends StatefulWidget {
  final dynamic orderNumber;
  final dynamic orderPlacedDate;

  const OrderItemListPage({
    super.key,
    required this.orderNumber,
    required this.orderPlacedDate,
  });

  @override
  State<StatefulWidget> createState() => OrderItemsState();
}

class OrderItemsState extends State<OrderItemListPage> {
  late String orderItemsUrl = 'http://175.111.182.125:8083/order/v1';
  Map<String, dynamic>? _itemsList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    orderItemsUrl = '$orderItemsUrl/${widget.orderNumber}';
    _isLoading = true;
    getOrderItems();
  }

  /// Show the error
  void _showErrorSnackBar(String message) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,

          // action button
          // action: SnackBarAction(
          //   label: "UNDO",
          //   textColor: Colors.yellow,
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text("Undo clicked")),
          //     );
          //   },
          // ),

          // Layout behavior
          behavior: SnackBarBehavior.floating, // floating or fixed
          margin: const EdgeInsets.all(16),   // margin when floating
          padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),  // padding inside snackbar
          // width: 350,                         // optional: fixed width

          // Shape & clipping
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,        // how edges are clipped

          // Dismiss & duration
          dismissDirection: DismissDirection.horizontal, // swipe direction
          duration: const Duration(seconds: 3),          // auto-hide time

          // Animation
          showCloseIcon: true, // adds a close "X" icon
          closeIconColor: Colors.white,      // padding inside snackbar
        ),
      );
    }
  }

  Future<void> getOrderItems() async {
    try {
      final response = await http.get(
        Uri.parse(orderItemsUrl),
        headers: {
          'Authorization': 'Bearer',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() {
          _itemsList = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      //
      _showErrorSnackBar(e.toString());
      // print('Error fetching order items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      backgroundColor: const Color(0xFF7AB2B2),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _itemsList == null
            ? Center(child: TextButton(onPressed: getOrderItems, child: const Text('Retry')))
            : SingleChildScrollView(child: _generateItemList()),
      ),
    );
  }

  Widget _generateItemList() {
    final lineItems = _itemsList?['lineItem'] as List? ?? [];
    final totalAmount = _itemsList?['total']?['amount']?.toString() ?? 'Unknown';

    return Column(
      children: [
        _orderDetailsSection(),
        const SizedBox(height: 20,),
        ...lineItems.map((item) => _productItem(item)),
        const SizedBox(height: 5,),
        _paymentSection(),
        const SizedBox(height: 5,),
        _shippingAddressSection(),
        const SizedBox(height: 5,),
        _orderSummarySection(totalAmount),
      ],
    );
  }

  Widget _orderDetailsSection() => _infoContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Order placed             ${widget.orderPlacedDate}'),
        Text('Order number           ${widget.orderNumber}'),
      ],
    ),
  );

  Widget _productItem(dynamic item) {
    final product = item['product'] ?? {};
    final image = product['image'] ?? 'assets/abended_city.png';
    final name = product['name'] ?? 'Unnamed';
    final quantity = item['quantity'] ?? '0';
    final unit = product['price']?['unit'] ?? '';
    final price = item['totalPrice']?['amount'] ?? '0';

    return _infoContainer(
      Row(
        children: [
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: NetworkImage(image), fit: BoxFit.fill),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$quantity $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentSection() => _infoContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(_itemsList?['payment Detail'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _shippingAddressSection() => _infoContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shipping Address', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(_itemsList?['customer'] ?? 'Not Provided'),
        Text(_itemsList?['shippingAddress']?['locality'] ?? 'Unknown'),
        Text(_itemsList?['shippingAddress']?['city'] ?? 'Unknown'),
        Text(_itemsList?['shippingAddress']?['state'] ?? 'Unknown'),
      ],
    ),
  );

  Widget _orderSummarySection(String totalAmount) => _infoContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Summary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Items Subtotal:'),
            Text('₹$totalAmount.00'),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping:'),
            Text('₹00.00'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('₹$totalAmount.00', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );

  Widget _infoContainer(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: Colors.white.withOpacity(0.7),
    ),
    child: child,
  );
}
