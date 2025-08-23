import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'singleProduct.dart';

void main() {
  runApp(const MaterialApp(
    home: FavoriteProducts(),
    debugShowCheckedModeBanner: false,
  ));
}

class FavoriteProducts extends StatelessWidget {
  const FavoriteProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return const FavItems();
  }
}

class FavItems extends StatefulWidget {
  const FavItems({super.key});

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<FavItems> {
  final ScrollController _scrollController = ScrollController();
  final List<String> favBtnColor = List.generate(3, (index) => 'Black');


  Map<String, dynamic> _itemsList = {};
  int limit = 5;
  String sortBy = '';
  String sortOption = "";
  String? accessToken;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
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


  /// Get All Products
  Future<void> fetchAlbum() async {

    try {
      final baseURL = Uri.parse(
          'http://localhost:8081/product/v1/products');
      final response = await http.get(
        (baseURL),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _itemsList.clear();
          _itemsList = jsonDecode(response.body);
          // print(_itemsList['limit']);
        });
      } else if (response.statusCode == 401) {
        throw Exception('Not Found: The resource does not exist');
      } else if (response.statusCode == 404) {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      } else {
        throw Exception('Failed to load Product.');
      }
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      // Error handling
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _refreshPage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    fetchAlbum(); // Fetch data again when the page is refreshed
  }

  void sortProduct(String option) {
    setState(() {
      sortOption = option;

      if (option == "a_to_z") {
        setState(() {
          sortBy = 'desc';
        });
        fetchAlbum();
      } else if (option == "z_to_a") {
        setState(() {
          sortBy = 'asc';
        });
        fetchAlbum();
      } else if (option == "low_to_high") {
      } else if (option == "high_to_low") {}
    });
  }

  void _showOverlay(BuildContext context, String text) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 59,
        left: MediaQuery.of(context).size.width * 0.3,
        right: MediaQuery.of(context).size.width * 0.3,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            color: Colors.greenAccent,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
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
                  ]),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _itemsList.isEmpty ?
              ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(
                      child: Text('Nothing to show'),
                    ),
                  ),
                ],
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
              child: Card(
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            width: MediaQuery.of(context).size.width * 1,
                            alignment: Alignment.topLeft,
                            child: Text(
                              '$productName',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          /// Price container
                          Container(
                            color: Colors.transparent, width:
                          MediaQuery.of(context).size.width * 1,
                            margin: const EdgeInsets.fromLTRB(0, 3, 5, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Price : ',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const Icon(
                                  Icons.currency_rupee,
                                  size: 17,
                                ),
                                Text(
                                  productPrice,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
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
                          ElevatedButton(
                              onPressed: () {
                                String text = 'Added to Favorite';
                                _showOverlay(context, text);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         ViewSingleProduct(
                                //       dataId: _itemsList['results']
                                //           [index]['id'],
                                //       dataCategory: "Shirt",
                                //     ),
                                //   ),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.fromLTRB(
                                    2, 0, 2, 0),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.horizontal(
                                    right: Radius.circular(10),
                                    left: Radius.circular(10),
                                  ),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.6),

                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                          ),
                          ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.horizontal(
                                  left: Radius.circular(7),
                                  right: Radius.circular(7),
                                ),
                              ),
                              elevation: 15,
                            ),
                            child: const Text(
                              "Buy",
                              style: TextStyle(fontSize: 16),
                            ),
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
