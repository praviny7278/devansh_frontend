import 'dart:async';
import 'dart:convert';

import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../homePage/homepage.dart';
import 'check_out_page.dart';

void main() {
  runApp(
    const MaterialApp(
      home: CartItemsPage(),
      debugShowCheckedModeBanner: false,
      color: Colors.green,
    ),
  );
}

class CartItemsPage extends StatefulWidget {
  const CartItemsPage({super.key});

  @override
  State<CartItemsPage> createState() => ViewProductState();
}

class ViewProductState extends State<CartItemsPage> {
  final TextEditingController searchController = TextEditingController();
  final SessionManager _sessionManager = SessionManager();
  List<double> _itemsCount = [];
  List<double> cartItemPrice = [];
  Map<String, dynamic> _productData = {};

  /// Map to track updated quantities dynamically
  Map<int, double> updatedQuantities = {};
  bool _cartStatus = false;
  String? _accessToken;
  String? _cartId = "";
  bool _isLoading = true;

  @override
  void dispose() {
    // searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserCartId();
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

  /// Get Cart id
  Future<void> getUserCartId() async {

    try {
      String? id = await _sessionManager.getUserCartId();

      if (id != null && id.isNotEmpty) {
        _cartId = id;
            fetchCartDataByID(_cartId!);
        print('cart Id: $_cartId');
      } else {
        throw ('Login first!');
      }
    } catch(e) {
      _showErrorSnackBar(e.toString());
    }
  }

  /// Get Product Data From API
  Future<void> fetchCartDataByID(String cartId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8083/cart/v1/$cartId'));
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          setState(() {
            _isLoading = false;

            _productData = jsonDecode(response.body);
            _cartStatus = _productData['status'];
            print(_productData['lineItems'].length);
            print(_productData['lineItems']);
            _itemsCount = List<double>.from(
                _productData['lineItems'].map((item) => item['quantity']));
            cartItemPrice = List<double>.from(_productData['lineItems'].map(
                (item) => (item['quantity'] * item['product']['price']['price'])
                    .toDouble()));
          });
        } else {
          // Handle empty response body
          throw ('Empty Cart');
        }
      } else {
        throw ("Failed to load data");
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  /// Update Cart Data - Changeable items quantity only
  Future<void> updateCartData() async {
    List<Map<String, dynamic>> updatedCartItems = [];

    for (var entry in updatedQuantities.entries) {
      final index = entry.key; // Index of the changed product
      updatedCartItems.add({
        'productName': _productData['lineItems'][index]['product']['name'],
        'quantity': entry.value, // Updated quantity
      });
    }
    String jsonBody = jsonEncode(updatedCartItems);

    try {
      final response = await http.put(
        Uri.parse(
            'http://localhost:8083/cart/v1/$_cartId/updateCart'),
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer $accessToken",
        },
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Cart updated successfully: ${response.body}");
        // if ((context as Element).mounted) {
          _showOverlay(context); // Show success overlay
        // }
        updatedQuantities.clear(); // Clear the tracking map
      } else {
        print("Failed to update cart: ${response.statusCode} - ${response.body}");
        throw ('Failed to update cart!');
      }
    } catch (e) {
      print("Error updating cart: $e");
      _showErrorSnackBar(e.toString());
    }
  }

  /// Delete cart Data - On Change Quantity
  Future<void> deleteCartData(String iD) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost:8083/cart/v1/$_cartId/remove/$iD'),
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer $accessToken",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Cart Line Item Deleted successfully: ${response.body}");
        _showOverlay(context); // Show success overlay
        updatedQuantities.clear(); // Clear the tracking map
      } else {
        throw Exception(
            "Failed to Delete cart data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error Deleting cart data: $e");
    }
    fetchCartDataByID(_cartId!);
  }

  /// Increment Quantity
  void _counterIncrement(int index) {
    setState(() {
      _itemsCount[index] += 0.25;
      cartItemPrice[index] +=
          _productData['lineItems'][index]['product']['price']['price'] / 4;

      // Track updated quantity in the map
      updatedQuantities[index] = _itemsCount[index];
    });
  }

  /// Decrement Quantity
  void _counterDecrement(int index) {
    setState(() {
      if (_itemsCount[index] > 0) {
        _itemsCount[index] -= 0.25;
        cartItemPrice[index] -=
            _productData['lineItems'][index]['product']['price']['price'] / 4;

        // Track updated quantity in the map
        updatedQuantities[index] = _itemsCount[index];
      }

      // Remove item if quantity is 0
      if (_itemsCount[index] == 0) {
        //Delete line item on quantity
        deleteCartData(_productData['lineItems'][index]['id']);

        // _productData['lineItems'].removeAt(index);

        // Update quantity according
        updatedQuantities.remove(index); // Remove from updates
      }
    });
  }

  /// Page refresh function
  Future<void> _refreshPage() async {
    await Future.delayed(const Duration(milliseconds: 500));

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CartItemsPage()),
    );
  }

  /// Show an overlay popup on successful
  void _showOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(15),
            color: Colors.green,
            child: const Text("Item removed"),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              ),
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFF8EB2B2),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  // color: Colors.blue,
                  child: const Text(
                    "Your Cart",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: !_cartStatus
                            ? Container(
                                alignment: Alignment.bottomCenter,

                                /// Home page navigation button on empty cart
                                child: SizedBox(
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
                            : Container(
                                height: containerHeight,
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 4),
                                // width: MediaQuery.of(context).size.height * 1,
                                // color: Colors.red,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _productData['lineItems'].length,
                                  itemBuilder: (context, index) {
                                    final productTitle =
                                        _productData['lineItems'][index]
                                            ['product']['name'];
                                    final productImage =
                                        _productData['lineItems'][index]
                                                ['product']['image'] ??
                                            'assets/milk.jpg';

                                    return GestureDetector(
                                      onTap: () {
                                        (index);
                                      },

                                      /// Product container
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        margin: const EdgeInsets.fromLTRB(
                                            5, 2, 4, 0),
                                        padding: const EdgeInsets.fromLTRB(
                                            14, 10, 3, 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
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
                                                    image: AssetImage(
                                                        productImage),
                                                    fit: BoxFit.fill),
                                              ),
                                            ),

                                            /// Product title, price, quantity & increment button, decrement button
                                            Container(
                                              margin: const EdgeInsets.only(left: 17),
                                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  /// Product Title
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 5, 0, 5),
                                                    child: Text(
                                                      "$productTitle",
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[

                                                      /// Product price
                                                      SizedBox(
                                                        width: 92,
                                                        child: Row(
                                                          children: <Widget>[
                                                            const Icon(Icons.currency_rupee),
                                                            Text(
                                                              cartItemPrice[index].toString(),
                                                              textAlign:
                                                              TextAlign
                                                                  .start,
                                                              style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      /// used for space
                                                      const SizedBox(
                                                        width: 40,
                                                      ),

                                                      /// Product price, quantity & increment button, decrement button
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[

                                                          /// Product quantity decrement
                                                          SizedBox(
                                                           height: 30,
                                                           width: 30,
                                                           child: FloatingActionButton(
                                                             heroTag:
                                                             "minus_$index",
                                                             onPressed: _itemsCount[
                                                             index] ==
                                                                 0
                                                                 ? null
                                                                 : () {
                                                               setState(() {
                                                                 _counterDecrement(
                                                                     index);
                                                               });
                                                             },
                                                             backgroundColor:
                                                             Colors.red,
                                                             child: const Icon(
                                                               Icons.remove,
                                                               color: Colors.white,
                                                             ),
                                                           ),
                                                         ),

                                                          /// Product quantity
                                                          SizedBox(
                                                           width: 50,
                                                           child: Text(
                                                             _itemsCount[index]
                                                                 .toString(),
                                                             textAlign:
                                                             TextAlign.center,
                                                             style:
                                                             const TextStyle(
                                                                 fontSize: 17,
                                                               fontWeight: FontWeight.bold,
                                                             ),
                                                           ),
                                                         ),

                                                          /// Product quantity increment
                                                          SizedBox(
                                                           width: 30,
                                                           height: 30,
                                                           child:
                                                           FloatingActionButton(
                                                             heroTag:
                                                             "plus_$index",
                                                             onPressed: () {
                                                               _counterIncrement(
                                                                   index);
                                                             },
                                                             backgroundColor:
                                                             Colors.green,
                                                             child: const Icon(
                                                               Icons.add,
                                                               color: Colors.white,
                                                             ),
                                                           ),
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
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
              ],
            ),

            /// Order Placed Button ////
            (_productData.isNotEmpty || !_cartStatus || _isLoading) ? const Text('')
                : Positioned(
              bottom: 10,
              left: 2,
              right: 2,
              child: TextButton(
                onPressed: () async {
                  await updateCartData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartCheckOutPage(),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
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
                  padding: const EdgeInsets.all(10),
                  // height: 50,
                  child: const Text(
                    "Checkout",
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
