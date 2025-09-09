import 'dart:async';
import 'dart:convert';

import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../homePage/homepage.dart';
import 'order_history.dart';

void main() {
  runApp(
    const MaterialApp(
      home: CartCheckOutPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class CartCheckOutPage extends StatefulWidget {
  const CartCheckOutPage({super.key});

  @override
  State<CartCheckOutPage> createState() => ViewProductState();
}

class ViewProductState extends State<CartCheckOutPage> {
  final SessionManager _sessionManager = SessionManager();


  final String _orderCreateURL = 'http://175.111.182.125:8083/order/v1/create';
  Map<String, dynamic> _productData = {};
  String _cartTotalPrice = '';

  /// Map to track updated quantities dynamically
  // Map<int, double> _updatedQuantities = {};
  bool _cartStatus = false;
  String? cartId;
  String _userId = '';
  String _orderId = '';
  // String? _accessToken;
  bool isLoading = false;



  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserCartId();
    getUserId();
  }




  /// Get Cart id
  Future<void> getUserCartId() async {

    try {
      String? id = await _sessionManager.getUserCartId();

      if (id != null && id.isNotEmpty) {
        cartId = id;
        fetchCartDataByID();
      } else {
        throw ('Cart Id not found!');
      }
    } catch(e) {
      print(e);
      _showErrorSnackBar(e.toString());
    }
  }


  /// Get User Id
  Future<void> getUserId() async {
    try {
      String? id = await _sessionManager.getUserId();
      if ( id != null && id.isNotEmpty) {
        setState(() {
          _userId = id;
        });
      } else {
        throw ('User id not found!');
      }
    } catch(e) {
      print(e);
      _showErrorSnackBar(e.toString());
    }
    // print(accessToken);
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

  /// on Register successfully
  // void showCustomSuccessDialog(BuildContext context) {
  //   BuildContext? dialogContext;
  //
  //   showGeneralDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     barrierLabel: "Dismiss",
  //     barrierColor: Colors.black.withOpacity(0.5),
  //     transitionDuration: const Duration(milliseconds: 300),
  //     pageBuilder: (ctx, anim1, anim2) {
  //       return const SizedBox.shrink();
  //     },
  //     transitionBuilder: (context, animation, secondaryAnimation, child) {
  //       dialogContext ??= context; // Capture dialog context only once
  //
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         Future.delayed(const Duration(seconds: 2), () {
  //           if (dialogContext != null && Navigator.of(dialogContext!).canPop()) {
  //             Navigator.of(dialogContext!).pop();// Now safe
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => const OrderList()),
  //             );
  //           }
  //         });
  //       });
  //
  //       return Transform.scale(
  //         scale: animation.value,
  //         child: Opacity(
  //           opacity: animation.value,
  //           child: AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             title: const Row(
  //               children: [
  //                 Icon(Icons.check_circle, color: Colors.green),
  //                 SizedBox(width: 8),
  //                 Text("Ok"),
  //               ],
  //             ),
  //             content: const Text("Your Order has been placed successfully."),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  /// Get Product Data From API
  Future<void> fetchCartDataByID() async {
    try {
      final response = await http.get(Uri.parse("http://175.111.182.125:8083/cart/v1/$cartId"));
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
      _showErrorSnackBar(e.toString());
    }
  }


  /// Create Order According Cart Items
  Future<void> createOrder() async {
    try {

      /// product map
      Map<String, dynamic> cartDetails = {
        'cartId': cartId,
        'customerId': _userId,
      };

      final response = await http.post(
        Uri.parse(_orderCreateURL),
        headers: {
          // 'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(cartDetails),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> orderData = {};
        setState(() {
          orderData = jsonDecode(response.body);

          _orderId = orderData['orderNumber'] ?? '';
          // _onLoadingSuccessOverlay(context);
        });
        // _onLoadingShowOverlay(context);
        print('Order created successfully:${response.body}');
      } else {
        throw Exception(
            'Failed to create Order;${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar(e.toString());
      print(e);
    }
  }

  /// Page refresh function
  // Future<void> _refreshPage() async {
  //   await Future.delayed(const Duration(milliseconds: 500));
  //
  //   // Navigator.of(context).pushReplacement(
  //   //     MaterialPageRoute(builder: (context) => const CartItemsPage()));
  // }


  /// Show Overlay after click on checkout button
  void _onLoadingShowOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4 - 100,
        left: 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.9),
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
    /// insert  another Overlay after success
    createOrder().then((_) {
      overlayEntry.remove();
      _onLoadingSuccessOverlay(context);
    }).catchError((onError) {
      overlayEntry.remove();
      print(onError);
    });
  }

  /// Show Overlay after Cart create successfully button
  void _onLoadingSuccessOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4 - 100,
        left: MediaQuery.of(context).size.width * 0.4 - 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.7,
            height: 170,
            padding: const EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.check_circle, color: Colors.green, size: 30),
                const SizedBox(height: 10,),
                const Flexible(
                  fit: FlexFit.loose,
                  child: Text("Your Order has been placed successfully."),
                ),
                const SizedBox(height: 13,),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text("Order number : $_orderId",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    /// Show loading for at least 2 seconds, then navigate to the next page
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OrderList()),
            (Route<dynamic> route) => false, // Remove all previous routes
      );

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
      body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: const Text(
                    "Checkout",
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
              bottom: 60,
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
              child: isLoading?
                  const Center(child: Text(''),)
                  : TextButton(
                      onPressed: () async {
                        setState(() {
                        isLoading = true;
                        });
                        _onLoadingShowOverlay(context);
                        // await createOrder();
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
    );
  }
}
