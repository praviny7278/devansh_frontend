import 'dart:convert';

import 'package:fad/productPage/cart.dart';
import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ViewSingleProduct(
    dataName: null,
    dataCategory: null,
  ));
}

class ViewSingleProduct extends StatefulWidget {
  final dynamic dataName;
  final dynamic dataCategory;

  const ViewSingleProduct(
      {super.key, required this.dataName, required this.dataCategory});

  @override
  State<ViewSingleProduct> createState() => ViewProductState();
}

class ViewProductState extends State<ViewSingleProduct> {
  final SessionManager _sessionManager = SessionManager();
  late String baseURL = 'http://localhost:8081';
  Map<String, dynamic>? _data;
  String? _accessToken;
  bool isVisible = false;

  bool isTrueOptionBtn1 = false;
  bool isTrueOptionBtn2 = false;
  bool isTrueOptionBtn3 = false;
  bool isTrueOptionBtn4 = false;

  bool isActiveSubButton = false;
  bool isActiveOTPButton = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    baseURL = 'http://localhost:8081/product/v1/product/${widget.dataName}';
    fetchDataByName();
    getAccessToken();
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

  /// Get Product Data By Id
  Future<void> fetchDataByName() async {
    try {
      final response = await http.get(
        Uri.parse(baseURL),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          setState(() {
            _data = jsonDecode(response.body);
          });
        }
      } else if (response.statusCode == 401) {
        throw Exception('Not Found: The resource does not exist');
      } else if (response.statusCode == 404) {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      _showErrorSnackBar(fetchDataByName);
    }
  }

  /// Create The Cart According The Product
  Future<void> createCart(Map<String, dynamic> orderData) async {
    try {
      List<dynamic> productList = [];

      productList.add(orderData);
      // print(productList);
      String jsonBody = jsonEncode(productList);

      final response = await http.post(
        Uri.parse('http://localhost:8083/cart/v1/1'),
        headers: {
          // 'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        // print(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Not Found: The resource does not exist');
      } else if (response.statusCode == 404) {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(_data?.length);
    final productName = _data?['name'] ?? "Not Provided";
    final productImg = _data?['image'] ?? 'assets/milk.jpg';
    final productPrice = _data?['price']['price'] ?? 'Not Provided';
    final productCategory = _data?['catagories'] ?? 'Not Provided';
    final productUnit = _data?['price']['unit'] ?? 'Not Provided';
    final productDesc = _data?['discription'] ?? 'Not Provided';
    const productQty = 1;

    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          color: Colors.green,
        ),
        child: TextButton(
          onPressed: () async {
            Map<String, dynamic> productData = {
              'productName': productName,
              'quantity': productQty
            };

            await createCart(productData);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartItemsPage()),
            );

            // print('object');
          },
          child: const Text('Add'),
        ),
      ),
      appBar: AppBar(
        title: const Text('Your Information'),
        backgroundColor: const Color(0xFFCDE8E5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF7AB2B2),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _data != null ? 1 : 0,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              /// Image Container /////
              Center(
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 10),
                  width: 200,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: productImg != null
                        ? DecorationImage(
                            image: NetworkImage(productImg),
                            fit: BoxFit.fill,
                          )
                        : null, // Handle null image
                  ),
                ),
              ),

              /// Title Container ////
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
                // width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  productName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              /// Category Container ////
              Container(
                margin: const EdgeInsets.only(top: 20, left: 10, right: 20),
                // width: MediaQuery.of(context).size.width * 0.8,
                alignment: Alignment.topLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Category',
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      productCategory,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              /// Price Container ////
              Container(
                // width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(top: 20, left: 10, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      // color: Colors.red,
                      width: MediaQuery.of(context).size.width * 0.4,
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.red,
                      width: MediaQuery.of(context).size.width * 0.4,
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          const Icon(Icons.currency_rupee),
                          Text(
                            '$productPrice/$productQty $productUnit',
                            style: const TextStyle(fontSize: 19),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// Options Container /////
              Container(
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                // width: MediaQuery.of(context).size.width * 0.8,
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    /// Purchase options Container ////
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                isActiveSubButton = true;
                                isActiveOTPButton = false;
                                isVisible = true;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 20,
                              ),
                              backgroundColor: isActiveSubButton
                                  ? Colors.green
                                  : Colors.blue,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7.0),
                                  bottomLeft: Radius.circular(7.0),
                                ),
                              ),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text(
                              'Subscription',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                isActiveOTPButton = true;
                                isActiveSubButton = false;
                                isVisible = false;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.only(bottom: 20, top: 20),
                              backgroundColor: isActiveOTPButton
                                  ? Colors.green
                                  : Colors.blue,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(7.0),
                                  bottomRight: Radius.circular(7.0),
                                ),
                              ),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text(
                              'One Time Purchase',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isVisible)
                      Container(
                        // height: 50,
                        margin: const EdgeInsets.only(top: 30, bottom: 8),
                        child: const Text(
                          'Recieve on',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),

                    /// Daily Routine options Containers ///
                    if (isVisible)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isTrueOptionBtn1 = true;
                                  isTrueOptionBtn2 = false;
                                  isTrueOptionBtn3 = false;
                                  isTrueOptionBtn4 = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 20.0),
                                backgroundColor: isTrueOptionBtn1
                                    ? Colors.green
                                    : Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    bottomLeft: Radius.circular(5.0),
                                  ),
                                ),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text(
                                '1 week',
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isTrueOptionBtn2 = true;
                                  isTrueOptionBtn1 = false;
                                  isTrueOptionBtn3 = false;
                                  isTrueOptionBtn4 = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 20.0),
                                backgroundColor: isTrueOptionBtn2
                                    ? Colors.green
                                    : Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.0),
                                    bottomLeft: Radius.circular(0.0),
                                  ),
                                ),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text(
                                '2 week',
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isTrueOptionBtn3 = true;
                                  isTrueOptionBtn2 = false;
                                  isTrueOptionBtn1 = false;
                                  isTrueOptionBtn4 = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 20.0),
                                backgroundColor: isTrueOptionBtn3
                                    ? Colors.green
                                    : Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0.0),
                                    bottomLeft: Radius.circular(0.0),
                                  ),
                                ),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text(
                                '3 week',
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isTrueOptionBtn4 = true;
                                  isTrueOptionBtn2 = false;
                                  isTrueOptionBtn3 = false;
                                  isTrueOptionBtn1 = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 20.0),
                                backgroundColor: isTrueOptionBtn4
                                    ? Colors.green
                                    : Colors.blue,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0),
                                  ),
                                ),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text(
                                '1 Month',
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),

              /// Description Container ///
              Container(
                margin: const EdgeInsets.only(
                    top: 40, left: 10, right: 10, bottom: 25),
                alignment: Alignment.topLeft,
                child: Text(
                  productDesc,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
