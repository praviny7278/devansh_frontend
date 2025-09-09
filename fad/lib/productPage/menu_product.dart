import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../sessionManager/sessionmanager.dart';
import 'singleProduct.dart';

void main() {
  runApp(const MaterialApp(
    home: MenuProducts(),
    debugShowCheckedModeBanner: false,
  ));
}

class MenuProducts extends StatelessWidget {
  const MenuProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return const MenuItems();
  }
}

class MenuItems extends StatefulWidget {
  const MenuItems({super.key});

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<MenuItems> {
  final ScrollController _scrollController = ScrollController();
  final SessionManager _sessionManager = SessionManager();
  List<dynamic> _itemsList = [];
  int limit = 5;
  String sortBy = '';
  String sortOption = "";
  String? accessToken;
  final productUrl = 'http://175.111.182.125:8081/product/v1/products';


  @override
  void initState() {
    super.initState();
    getAccessToken();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        limit += 5;
        fetchAlbum();
      }
    });
    fetchAlbum(); // Fetch data when the widget is initialized
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
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

  /// Get access token
  Future<void> getAccessToken() async {
    try {
      accessToken = await _sessionManager.getAccessToken();
      setState(() {});
      print(accessToken);
    } catch(e) {
      _showErrorSnackBar(e.toString());
    }
  }

  /// Get All Products
  Future<void> fetchAlbum() async {

    try {
      final baseURL = Uri.parse(productUrl);
      final response = await http.get(
        (baseURL),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _itemsList.clear();
          _itemsList = jsonDecode(response.body);
          print(_itemsList);
        });
      } else if (response.statusCode == 401) {
        throw ('Not Found: The resource does not exist');
      } else if (response.statusCode == 404) {
        throw ('Failed to load data: ${response.reasonPhrase}');
      } else {
        throw ('Failed to load Product.');
      }
    } catch(e) {
      _showErrorSnackBar(e.toString());
    }


  }




  /// sort product according
  void sortProduct(String option, {bool local = true}) {
    setState(() {
      sortOption = option;

      switch (option) {
        case "a_to_z":
          sortBy = 'asc';
          if (local) {
            _itemsList.sort((a, b) => a['name']
                .toString()
                .toLowerCase()
                .compareTo(b['name'].toString().toLowerCase()));
          }
          break;

        case "z_to_a":
          sortBy = 'desc';
          if (local) {
            _itemsList.sort((a, b) => b['name']
                .toString()
                .toLowerCase()
                .compareTo(a['name'].toString().toLowerCase()));
          }
          break;

        case "low_to_high":
          sortBy = 'price_asc';
          if (local) {
            _itemsList.sort((a, b) => double.parse(a['price']['price'].toString())
                .compareTo(double.parse(b['price']['price'].toString())));
          }
          break;

        case "high_to_low":
          sortBy = 'price_desc';
          if (local) {
            _itemsList.sort((a, b) => double.parse(b['price']['price'].toString())
                .compareTo(double.parse(a['price']['price'].toString())));
          }
          break;
      }
    });

    if (!local) {
      fetchAlbum(); // hit backend for sorted data
    }
    print('Sorted by: $sortBy (local = $local)');
  }

  ///
  void _showOverlay(BuildContext context, String text) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 59,
        left: MediaQuery.of(context).size.width * 0.25,
        right: MediaQuery.of(context).size.width * 0.25,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(text),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Timer(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  ///
  Future<void> _refreshPage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    fetchAlbum(); // Fetch data again when the page is refreshed
    print('object');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDE8E5).withOpacity(0.4),
        title: const Text('Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (option) => sortProduct(option),
              itemBuilder: (context) => [
                    const PopupMenuItem(value: "a_to_z", child: Text("A to Z")),
                    const PopupMenuItem(value: "z_to_a", child: Text("Z to A")),
                    const PopupMenuItem(
                        value: "low_to_high", child: Text("Low to High")),
                    const PopupMenuItem(
                        value: "high_to_low", child: Text("High to Low")),
              ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFF7AB2B2),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: _itemsList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                // controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.69,
                  mainAxisSpacing: 8,
                ),
                itemCount: _itemsList.length,
                itemBuilder: (context, index) {
                  final productName =
                      _itemsList[index]['name'] ?? "Not Provided";
                  final productPrice =
                      _itemsList[index]['price']['price'].toString() ?? "Not Provided";
                  // final productPrice = '34' ?? 'Unknown';
                  final productImg =
                      _itemsList[index]['image'] ?? 'assets/milk.jpg';
                  return GestureDetector(
                          onTap: () {},
                          // elevation: 1,
                          // clipBehavior: Clip.antiAlias,
                          child: Card(
                            color: Colors.white.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                /// Product Image
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: ClipRRect (
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        productImg,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                ),
                                /// Product Title and Price column
                                Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                                    child:  Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        /// Title container
                                        Container(
                                        // // width: MediaQuery.of(context).size.width * 1,
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '$productName',
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        /// Price container
                                        Container(
                                          color: Colors.transparent, width:
                                          MediaQuery.of(context).size.width * 1,
                                          margin: const EdgeInsets.fromLTRB(0, 3, 5, 0),
                                          child: Text(
                                            'Price : ₹$productPrice',
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                /// Buttons for Add to cart & Buy
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                  child:  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      /// Button to Buy
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewSingleProduct(
                                                    dataName: _itemsList[index]
                                                    ['name'],
                                                    dataCategory: _itemsList[index]
                                                    ['catagories'],
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Buy",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      /// Button Add to wishList
                                      IconButton(
                                        tooltip: 'Favorite',
                                        onPressed: () {
                                          String text = 'Added to wishlist';
                                          _showOverlay(context, text);
                                        },
                                        icon: const Icon(Icons.favorite_border),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                },
              ),
      ),
    );
  }
}
