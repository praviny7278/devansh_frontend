import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fad/auth/login.dart';
import 'package:fad/user_info_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../productPage/cart.dart';
import '../productPage/menu_product.dart';
import '../productPage/singleProduct.dart';
import '../sessionManager/sessionmanager.dart';
import '../setting.dart';


// const String productBaseURL = 'http://175.111.182.125:8081/product/v1/products';
const String productBaseURL = 'http://175.111.182.125:8081/product/v1/products';





final connectivityProvider = StateProvider<bool>((ref) => true);

///
final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

final productProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final sessionManager = ref.read(sessionManagerProvider);

  // Get stored access token
  String? accessToken = await sessionManager.getAccessToken();


  // If access token is null, set a new one
  if (accessToken == null) {
    accessToken = "mock_access_token_123"; // Replace with real token logic
    await sessionManager.setAccessToken(accessToken);
  }


  return await fetchProductData(accessToken);
});

///
final customerProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final sessionManager = ref.read(sessionManagerProvider);

  // Get stored access token
  String? accessToken = await sessionManager.getAccessToken();
  String? userId = await sessionManager.getUserId();
  print('userId: $userId');

  // If access token is null, set a new one
  if (accessToken == null) {
    accessToken = "mock_access_token_123"; // Replace with real token logic
    await sessionManager.setAccessToken(accessToken);
  }

  return await fetchCustomerData(accessToken, userId!);
});




/// Get Customer information
Future<Map<String, dynamic>> fetchCustomerData(String? accessToken, String userId) async {
  try {
    final response = await http.get(
      Uri.parse('http://175.111.182.125:8082/customer/v1/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {

        final customerData = jsonDecode(response.body);
        return customerData;

    } else if (response.statusCode == 401) {
      throw ('Unauthorized: Invalid token');
      // print('Unauthorized: Invalid token');
    } else if (response.statusCode == 404) {
      // print('Not Found: The resource does not exist');
      throw ('Not Found: The resource does not exist');
    } else {
      // print('Failed to load data: ${response.reasonPhrase}');
      throw ('Failed to load data: ${response.reasonPhrase}');
    }
  } catch (error) {
     // _showErrorSnackBar(fetchCustomerData);
    throw ('Failed to load data: ${error.toString()}');
  }
}

/// Get Product information
Future<List<dynamic>> fetchProductData(String? accessToken) async {
  try {
    final response = await http.get(
      Uri.parse(productBaseURL),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final productData = jsonDecode(response.body);
      // print(_productData.length);
        return productData;
    } else if (response.statusCode == 401) {
      throw ('Unauthorized: Invalid token');
      // print('Unauthorized: Invalid token');
    } else if (response.statusCode == 404) {
      // print('Not Found: The resource does not exist');
      throw ('Not Found: The resource does not exist');
    } else {
      // print('Failed to load data: ${response.reasonPhrase}');
      throw ('Failed to load data: ${response.reasonPhrase}');
    }
  } catch (error) {
    // _showErrorSnackBar(fetchProductData);
    throw ('Failed to load data: ${error.toString()}');
  }
}

///
Future<void> _updateConnectionStatus(ConnectivityResult result, WidgetRef ref, BuildContext context) async {
  final hasConnection = result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;

  ref.read(connectivityProvider.notifier).state = hasConnection;

  if (hasConnection) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(Icons.wifi),
            Text('Internet restored')
          ],
        ),
        backgroundColor: Colors.green,
        // duration: Duration(seconds: 2),
      ),
    );

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(Icons.wifi_off_outlined),
            Text('Internet Disconnect')
          ],
        ),
        backgroundColor: Colors.red,
        // duration: Duration(seconds: 2),
      ),
    );
  }
}




class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController searchController = TextEditingController();
  final Connectivity _connectivity = Connectivity();


  //
  late StreamSubscription<ConnectivityResult> _subscription;
  late ScaffoldMessengerState _scaffoldMessenger;
  List<dynamic> _searchResults = [];
  bool _isSearching = false;




  @override
  void initState() {
    super.initState();
    Future.microtask((){
      ref.watch(productProvider);
      ref.watch(customerProvider);
      _subscription = _connectivity.onConnectivityChanged.listen(
              (result) => _updateConnectionStatus(result, ref, context),
      );
    });
    // setAccessToken();
    //
    // _subscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus as void Function(ConnectivityResult event)?);
    // _checkInitialConnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    searchController.dispose();
    _subscription.cancel();
    // customerProvider.dispose
    super.dispose();
  }


  ///
  void filterData(String query, List<dynamic> productData) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = productData;
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = productData
            .where((item) => item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  ///
  void clearSearch() {
    setState(() {
      // _searchResults = _productData;
      _isSearching = false;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {

    final productAsyncValue = ref.watch(productProvider);
    final customerAsyncValue = ref.watch(customerProvider);
    
    // ref.listen<bool>(connectivityProvider, (previous, next) {
    //   if (!next) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('No connection'),
    //           backgroundColor: Colors.red,
    //           duration: Duration(seconds: 2),
    //         ),
    //     );
    //   }
    // });

    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (_isSearching) {
          clearSearch(); // clear the search on click
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
          /// Customer Name
          title: customerAsyncValue.when(
            data: (customerData) {
                final name = customerData.isNotEmpty ? customerData['firstName'] : ['Hello!'];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Hello $name',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserInfoEditPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(left: 5.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                            image: NetworkImage('assets/user-avatar.png'),
                            fit: BoxFit.fill,
                          ), // Handle null image
                        ),
                      ),
                    ),
                  ],
                );
              },
            loading: () => const Text('Loading...'), // Show loading text
            error: (error, stackTrace) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text('Hello!'),
                const SizedBox(width: 6,),
                FloatingActionButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  heroTag: "User",
                  tooltip: 'User',
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  mini: true,
                  splashColor: Colors.white30,
                  backgroundColor: Colors.white60,
                  child: const Icon(
                    Icons.person,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ],
            ), // Show error message
          ),
        ),
        backgroundColor: const Color(0xFF7AB2B2),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.refresh(customerProvider);
            ref.refresh(productProvider);
          },
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                splashColor: Colors.white10,
                                backgroundColor: Colors.white70,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  size: 22,
                                ),
                              ),

                              /// Address Container
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                margin: const EdgeInsets.fromLTRB(8, 5, 0, 0),
                                child: customerAsyncValue.when(
                                  data: (customerData) {
                                    final address = customerData.isNotEmpty ? customerData['address'][0]['locality'] :
                                        '';
                                    return Text(address);
                                  },
                                  loading: () => const Text('Loading...'), // Show loading text
                                  error: (error, stackTrace) => const Text(''), // Show error message
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
                              onChanged:(value) =>  filterData(value, productAsyncValue.value ?? []),
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
                    height: (screenHeight * 1) - 253,
                    padding: const EdgeInsets.only(bottom: 0),
                    width: MediaQuery.of(context).size.width * 1,
                    child: _isSearching

                        /// On search view container
                        ? productAsyncValue.when(
                          data: (products) => ListView.builder(

                            itemCount: _isSearching ? _searchResults.length : products.length,
                            itemBuilder: (context, index) {
                              final product = _isSearching ? _searchResults[index] : products[index];
                              final productName =
                                  product['name'] ?? 'Not Provided';
                              final productImg =
                                  product['image'] ?? 'assets/milk.jpg';
                              return GestureDetector(

                                /// Navigation to the Product page onClick
                                onTap: () {
                                  if (_isSearching) {
                                    clearSearch();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewSingleProduct(
                                          dataName: product['name'],
                                          dataCategory: product['catagories']
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
                                      productName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),

                                    /// Product image
                                    leading: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: productImg != null
                                            ? DecorationImage(
                                          image:
                                          NetworkImage(productImg),
                                          fit: BoxFit.fill,
                                        )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          error: (error, stack) => const Center(
                            child: Text('Product Not Found!'),
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )

                        /// Normal grid view container
                        : productAsyncValue.when(
                        data: (productData) => GridView.builder(
                        // shrinkWrap: true,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.76,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: productData.length,
                        itemBuilder: (context, index) {
                          final prodTitle =
                              productData[index]['name'] ?? "Not Provided";
                          final prodImage = productData[index]['image'] ??
                              "assets/milk.jpg";
                          return GestureDetector(

                            /// Navigation to the Product page onClick
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewSingleProduct(
                                    dataName: productData[index]['name'],
                                    dataCategory: productData[index]
                                    ['catagories'],
                                  ),
                                ),
                              );
                            },

                            /// Product title and image container
                            child: Card(
                              elevation: 4,
                              margin:
                              const EdgeInsets.fromLTRB(10, 5, 10, 10),
                              color: Colors.white.withOpacity(0.7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[

                                  /// Product image
                                  Expanded(
                                    child: ClipRRect (
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(
                                          prodImage,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                      ),
                                    )
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
                        error: (Object error, StackTrace stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Error loading data'),
                            ElevatedButton(

                              onPressed: () {
                                // Reload the customer provider when error happens
                                ref.refresh(customerProvider);
                                ref.refresh(productProvider);
                                print('object');
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ), // Show error message,
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                      ),
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
