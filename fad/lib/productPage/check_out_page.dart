import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../homePage/homepage.dart';

void main() {
  runApp(
    const MaterialApp(
      home: CartCheckOutPage(),
      debugShowCheckedModeBanner: false,
      color: Colors.green,
    ),
  );
}

class CartCheckOutPage extends StatefulWidget {
  const CartCheckOutPage({super.key});

  @override
  State<CartCheckOutPage> createState() => ViewProductState();
}

class ViewProductState extends State<CartCheckOutPage> {
  late String baseURL =
      "http://localhost:8083/cart/v1/9bf2e2b6-69fa-4e43-8028-5fde80f11f9c";
  String orderURL = 'http://localhost:8083/order/v1/create';
  Map<String, dynamic> _productData = {};
  String _cartTotalPrice = '';

  /// Map to track updated quantities dynamically
  Map<int, double> updatedQuantities = {};
  bool _cartStatus = false;
  String? _accessToken;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCartDataByID();
  }

  /// On Error Throw callback
  void _showErrorSnackBar(VoidCallback retryFunction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Something went wrong.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => retryFunction, // Retry the operation
        ),
        duration:
            const Duration(hours: 1), // Persistent until manually dismissed
      ),
    );
  }

  /// Get Product Data From API
  Future<void> fetchCartDataByID() async {
    try {
      final response = await http.get(Uri.parse(baseURL));
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          setState(() {
            _productData = jsonDecode(response.body);
            print(_productData);

            _cartStatus = _productData['status'];
            _cartTotalPrice = _productData['cartTotal']['amount'].toString();
          });

          // print(_productData['lineItems'].length);
        } else {
          // Handle empty response body
          print('Empty response body');
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      _showErrorSnackBar(fetchCartDataByID);
    }
  }

  /// Create Order According Cart Items
  Future<void> createOrder() async {
    try {
      Map<String, dynamic> cartDetails = {
        'cartId': '9bf2e2b6-69fa-4e43-8028-5fde80f11f9c',
        'customerId': '2',
      };

      final response = await http.post(
        Uri.parse(orderURL),
        headers: {
          // 'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(cartDetails),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Order created successfully:${response.body}');
      } else {
        print(
            'Failed to create Order;${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showErrorSnackBar(createOrder);
    }
  }

  /// Page refresh function
  Future<void> _refreshPage() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => const CartItemsPage()));
  }

  void _showOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 220,
        left: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.5),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 8,
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Timer(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double containerHeight;

    /// Set containerHeight based on screenHeight
    if (screenHeight < 700) {
      containerHeight = screenHeight * 0.83;
    } else {
      containerHeight = screenHeight * 0.845;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devansh Dairy'),
        backgroundColor: const Color(0xFFCDE8E5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF8EB2B2),
      body: RefreshIndicator(
        /// Refresh Indicator
        onRefresh: _refreshPage,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  // color: Colors.blue,

                  child: const Text(
                    "Your Cart",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),

                /// Check wither the Cart is not Empty or Cart status is True
                _productData.isEmpty
                    ? const CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: !_cartStatus

                            /// Button for Home page if cart is empty
                            ? Container(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 300,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Home()),
                                      );
                                    },
                                    child: const Text("Go to home Page"),
                                  ),
                                ),
                              )

                            /// Product container
                            : Container(
                                height: containerHeight,
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 4),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _productData['lineItems'].length,
                                  itemBuilder: (context, index) {
                                    final productTitle =
                                        _productData['lineItems'][index]
                                                ['product']['name'] ??
                                            'Unknown';
                                    final productImage =
                                        _productData['lineItems'][index]
                                                ['product']['image'] ??
                                            'assets/milk.jpg';
                                    final productPrice =
                                        _productData['lineItems'][index]
                                                ['product']['price']['price'] ??
                                            'Unknown';
                                    final productQty = _productData['lineItems']
                                            [index]['quantity'] ??
                                        'Unknown';
                                    final productTotalPrice =
                                        _productData['lineItems'][index]
                                                ['totalPrice']['amount'] ??
                                            'Unknown';

                                    /// Product Container
                                    return Container(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 2, 4, 0),
                                      padding: const EdgeInsets.fromLTRB(
                                          14, 10, 3, 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      child: Row(
                                        children: [
                                          /// Product Image
                                          Container(
                                            alignment: Alignment.center,
                                            // padding: const EdgeInsets.only(left: 10),
                                            width: 65,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                  image:
                                                      AssetImage(productImage),
                                                  fit: BoxFit.fill),
                                            ),
                                          ),

                                          /// Product Title, Rate, Quantity, Total Amount
                                          Container(
                                            // alignment: Alignment.topLeft,
                                            // padding: const EdgeInsets.only(left: 20),
                                            margin:
                                                const EdgeInsets.only(left: 17),
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 5, 0, 5),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            // color: Colors.blue,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /// Product Title
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 5, 0, 5),
                                                  child: Text(
                                                    "$productTitle",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),

                                                /// Product Rate, Quantity & Total Amount
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    /// Product Rate & Quantity
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          '$productQty * $productPrice',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: const TextStyle(
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),

                                                    /// Product Total Amount
                                                    Row(
                                                      children: <Widget>[
                                                        const Icon(Icons
                                                            .currency_rupee),
                                                        Text(
                                                          '$productTotalPrice',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: const TextStyle(
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
              ],
            ),

            /// Customer Details & Cart Total
            Positioned(
              bottom: 55,
              left: 5,
              right: 5,
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /// Customer Name
                    Text(
                      'Dev',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// Cart Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Cart Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.currency_rupee,
                              size: 20,
                            ),
                            Text(
                              _cartTotalPrice,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    /// Delivery Charges
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Delivery Charges',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              size: 20,
                            ),
                            Text(
                              '00.0',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    /// Total Payble Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.currency_rupee,
                              size: 20,
                            ),
                            Text(
                              _cartTotalPrice,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            /// Order  Button
            Positioned(
              bottom: 10,
              left: 1,
              right: 1,
              child: TextButton(
                onPressed: () async {
                  await createOrder();
                  _showOverlay(context);
                  // print('Button clicked!');
                  // await updateCartData();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const CheckOutPage()),
                  // );
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    color: Colors.green,
                  ),
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  // height: 50,
                  child: const Text(
                    "Place Order",
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
