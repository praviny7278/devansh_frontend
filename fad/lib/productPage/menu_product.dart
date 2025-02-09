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
  String? _accessToken;
  final productUrl = 'http://localhost:8081/product/v1/products';

  @override
  void initState() {
    super.initState();
    getAccessToken();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        limit += 5;
        fetProductData();
      }
    });
    fetProductData(); // Fetch data when the widget is initialized
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  /// Access The Token
  Future<void> getAccessToken() async {
    try {
      String? token = await _sessionManager.getAccessToken();
      setState(() {
        _accessToken = token;
      });
      print(_accessToken);
    } catch (e) {
      print(e);
    }
  }

  /// Get Access Token
  Future<void> fetProductData() async {
    final baseURL = Uri.parse(productUrl);
    final response = await http.get(
      (baseURL),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
    );

    if (response.statusCode == 200) {
      setState(() {
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
  }

  /// Page refresh function
  Future<void> _refreshPage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    fetProductData(); // Fetch data again when the page is refreshed
    print('object');
  }

  /// Sort product according Ascending and Descending
  void sortProduct(String option) {
    setState(() {
      sortOption = option;

      if (option == "a_to_z") {
        setState(() {
          sortBy = 'desc';
        });
        fetProductData();
      } else if (option == "z_to_a") {
        setState(() {
          sortBy = 'asc';
        });
        fetProductData();
      } else if (option == "low_to_high") {
      } else if (option == "high_to_low") {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDE8E5).withOpacity(0.4),
        title: const Text('Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          /// Option for sorting in various type
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
      backgroundColor: const Color(0xFF7AB2B2),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: _itemsList.isEmpty
            ? const Center(
                /// Refresh indicator
                child: CircularProgressIndicator(),
              )

            /// Generating the gridview
            : GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  childAspectRatio: .69,
                  mainAxisSpacing: 0,
                ),
                itemCount: _itemsList.length,
                itemBuilder: (context, index) {
                  /// Declaration and Assign value in variables
                  final productName =
                      _itemsList[index]['name'] ?? "Not Provided";
                  // final productPrice =
                  //     _itemsList[index]['price']['price'].toString();
                  final productPrice = '34';
                  final productImg =
                      _itemsList[index]['image'] ?? 'assets/milk.jpg';

                  /// Product container
                  return GridTile(
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 7,
                              left: 10,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.white.withOpacity(0.6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                /// Product image
                                Container(
                                  height: 145,
                                  // width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: productImg != null
                                        ? DecorationImage(
                                            image: NetworkImage(productImg),
                                            fit: BoxFit.fill,
                                          )
                                        : null,
                                  ),
                                ),

                                /// Product Title and Price container
                                Container(
                                  color: Colors.transparent,
                                  width: MediaQuery.of(context).size.width * 1,
                                  margin: const EdgeInsets.fromLTRB(5, 8, 5, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      /// Product Title container
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        alignment: Alignment.topLeft,

                                        /// Product Title
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

                                      /// Product Price container
                                      Container(
                                        color: Colors.transparent,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 3, 5, 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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

                                            /// Product currency icon
                                            const Icon(
                                              Icons.currency_rupee,
                                              size: 17,
                                            ),

                                            /// Product price
                                            Text(
                                              productPrice,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Button container for add to cart and favorite
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 0,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.99,
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      /// Button for add Product in Cart
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

                                      /// Button for add Product in Favorite
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.fromLTRB(
                                                9, 0, 9, 0),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                right: Radius.circular(7),
                                                left: Radius.circular(7),
                                              ),
                                            ),
                                            backgroundColor: Colors.red,
                                            elevation: 15),
                                        child: const Text(
                                          "Favorite",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
