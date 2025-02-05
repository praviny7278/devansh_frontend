import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../productPage/cart.dart';
import '../productPage/menu_product.dart';
import '../productPage/singleProduct.dart';
import '../sessionManager/sessionmanager.dart';
import '../setting.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SessionManager _sessionManager = SessionManager();
  final TextEditingController searchController = TextEditingController();
  late StreamSubscription<ConnectivityResult> _subscription;
  final Connectivity _connectivity = Connectivity();
  String _connectionStatus = 'Unknown';
  bool _connectivityStatus = true;

  final String productBaseURL = 'http://localhost:8081/product/v1/products';
  final String customerBaseURL = 'http://localhost:8082/customer/v1/1';

  Map<String, dynamic> _customerData = {};
  List<dynamic> _productData = [];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String? accessToken;
  // String? customerName;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchProductData();
    getAccessToken();
    setAccessToken();
    fetchCustomerData();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
          _connectionStatus = 'Internet connected';
          _connectivityStatus = true;
          break;
        case ConnectivityResult.none:
          _connectionStatus = 'No internet connection';
          _connectivityStatus = false;
          break;
        default:
          _connectionStatus = 'Unknown';
          _connectivityStatus = false;
          break;
      }
    });
    print('Connection Status: $_connectionStatus');
    _showOverlay(context, _connectionStatus, _connectivityStatus);
  }

  Future<void> setAccessToken() async {
    await _sessionManager.setAccessToken('token');
  }

  Future<void> getAccessToken() async {
    accessToken = await _sessionManager.getAccessToken();
    setState(() {});
    // print(accessToken);
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

  /// Get Customer information
  Future<void> fetchCustomerData() async {
    try {
      final response = await http.get(
        Uri.parse(customerBaseURL),
        // headers: {
        //   'Authorization': 'Bearer $accessToken',
        //   'Content-Type': 'application/json',
        // },
      );

      if (response.statusCode == 200) {
        setState(() {
          _customerData = jsonDecode(response.body);
          // print(_customerData);
        });
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
        // print('Unauthorized: Invalid token');
      } else if (response.statusCode == 404) {
        // print('Not Found: The resource does not exist');
        throw Exception('Not Found: The resource does not exist');
      } else {
        // print('Failed to load data: ${response.reasonPhrase}');
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar(fetchCustomerData);
      throw Exception('Failed to load data: ${error.toString()}');
    }
  }

  /// Get Product information
  Future<void> fetchProductData() async {
    try {
      final response = await http.get(
        Uri.parse(productBaseURL),
        // headers: {
        //   'Authorization': 'Bearer $accessToken',
        //   'Content-Type': 'application/json',
        // },
      );

      if (response.statusCode == 200) {
        setState(() {
          _productData = jsonDecode(response.body);
          // print(_productData.length);
          // _searchResults = _data;
        });
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid token');
        // print('Unauthorized: Invalid token');
      } else if (response.statusCode == 404) {
        // print('Not Found: The resource does not exist');
        throw Exception('Not Found: The resource does not exist');
      } else {
        // print('Failed to load data: ${response.reasonPhrase}');
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar(fetchProductData);
      throw Exception('Failed to load data: ${error.toString()}');
    }
  }

  void _showOverlay(
      BuildContext context, String text, bool connectivityStatus) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 5,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: connectivityStatus ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 19, color: Colors.white),
            ),
          ),
        ),
      ),
    );

    connectivityStatus ? "" : overlayState.insert(overlayEntry);

    Timer(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  /// Page refresh function
  Future<void> _refreshPage() async {
    Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => const Home()));
  }

  void filterData(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = _productData;
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = _productData
            .where((item) => item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
      print(_productData
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList());
    }
  }

  void clearSearch() {
    setState(() {
      _searchResults = _productData;
      _isSearching = false;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = 0.0;

    if (screenHeight < 700) {
      containerHeight = screenHeight * 0.69;
    } else {
      containerHeight = screenHeight * 0.73;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (_isSearching) {
          clearSearch();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        bottomNavigationBar: SafeArea(
          /// Bottom navigation buttons container
          child: Container(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomRight: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
              color: Colors.black54,
            ),

            /// Bottom navigation buttons
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                /// Home Button with icon
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  },
                  tooltip: 'Home',
                  heroTag: "Home",
                  mini: true,
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.white70,
                  child: const Icon(
                    Icons.home,
                    size: 22,
                    color: Colors.green,
                  ),
                ),

                /// Category Button with icon
                FloatingActionButton(
                  onPressed: () {
                    // print('Menu');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuProducts()),
                    );
                  },
                  tooltip: 'Category',
                  heroTag: "Category",
                  mini: true,
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.transparent,
                  child: const Icon(
                    Icons.category,
                    size: 22,
                    color: Colors.green,
                  ),
                ),

                /// Cart Button with icon
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartItemsPage()),
                    );
                  },
                  tooltip: 'Cart',
                  heroTag: "Cart",
                  mini: true,
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.transparent,
                  child: const Icon(
                    Icons.shopping_cart,
                    size: 22,
                    color: Colors.green,
                  ),
                ),

                /// App Setting Button with icon
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Setting()),
                    );
                  },
                  tooltip: 'Menu',
                  heroTag: "Menu",
                  elevation: 15,
                  mini: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.transparent,
                  child: const Icon(
                    Icons.menu,
                    size: 22,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0),
              child: Container(
                color: const Color(0xFFCDE8E5),
              ),
            ),
          ),
          // backgroundColor: Colors.red,
          /// User Name
          title: Text(
            _customerData['firstName'] ?? 'Not Provided',
            textAlign: TextAlign.right,
          ),
        ),
        backgroundColor: const Color(0xFF7AB2B2),
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /// Location and Search bar Container
                  Container(
                    height: 130,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                      color: Color(0xFFEEF7FF),
                    ),
                    child: Column(
                      children: <Widget>[
                        /// Location Button and address container
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              /// Location Button
                              FloatingActionButton(
                                onPressed: () {},
                                heroTag: "Location",
                                tooltip: 'Location',
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                mini: true,
                                splashColor: Colors.green,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  size: 22,
                                ),
                              ),

                              /// Address Container
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                margin: const EdgeInsets.fromLTRB(8, 5, 0, 0),
                                child: Text(
                                  _customerData['address'][0]['locality'] ??
                                      'Not Provided',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Search bar
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 1,
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          color: const Color(0xFF7AB2B2),
                          child: Material(
                            color: const Color(0xFFebeef2),
                            child: TextField(
                              controller: searchController,
                              keyboardType: TextInputType.multiline,
                              onChanged: filterData,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                prefixIcon: const Icon(Icons.search),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(
                                          int.parse('CBCBCBDB', radix: 16))),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Product container
                  Container(
                    alignment: Alignment.center,
                    color: const Color(0xFF7AB2B2),
                    height: (screenHeight * 1) - 254,
                    padding: const EdgeInsets.only(bottom: 0),
                    width: MediaQuery.of(context).size.width * 1,
                    child: _isSearching

                        /// On search view container
                        ? ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              final categoryName =
                                  item[index]['name'] ?? 'Not Provided';
                              final categoryImg =
                                  item[index]['image'] ?? 'assets/milk.jpg';
                              // print(_searchResults);
                              return GestureDetector(
                                /// Navigation to the Product page onClick
                                onTap: () {
                                  // print(_searchResults[index]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewSingleProduct(
                                        dataName: item[index]['productId'],
                                        dataCategory: "category",
                                      ),
                                    ),
                                  );
                                },

                                /// Product title and image container
                                child: Container(
                                  color: const Color(0xFFebeef2),
                                  margin: const EdgeInsets.only(
                                      top: 0, bottom: 1, left: 5, right: 5),
                                  height: 60,
                                  alignment: Alignment.centerLeft,
                                  child: ListTile(
                                    autofocus: true,

                                    /// Product title
                                    title: Text(
                                      categoryName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),

                                    /// Product image
                                    leading: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: categoryImg != null
                                            ? DecorationImage(
                                                image:
                                                    NetworkImage(categoryImg),
                                                fit: BoxFit.fill,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )

                        /// Normal view container
                        : GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0,
                              childAspectRatio: 0.76,
                              crossAxisSpacing: 0,
                            ),
                            itemCount: _productData.length,
                            itemBuilder: (context, index) {
                              final prodTitle =
                                  _productData[index]['name'] ?? "Not Provided";
                              final prodImage = _productData[index]['image'] ??
                                  "assets/milk.jpg";
                              return GestureDetector(
                                /// Navigation to the Product page onClick
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewSingleProduct(
                                        dataName: _productData[index]['name'],
                                        dataCategory: _productData[index]
                                            ['catagories'],
                                      ),
                                    ),
                                  );
                                },

                                /// Product title and image container
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      /// Product image
                                      Container(
                                        margin: const EdgeInsets.all(10),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.21,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          image: prodImage != null
                                              ? DecorationImage(
                                                  image:
                                                      NetworkImage(prodImage),
                                                  fit: BoxFit.fill,
                                                )
                                              : null,
                                        ),
                                      ),

                                      /// Product title
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            bottom: 5),
                                        child: Text(
                                          '$prodTitle',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color:
                                                Colors.black45.withOpacity(0.9),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 2,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
