import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/error_throw_widget.dart';

void main() => runApp(const OrderHistory());

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Order History'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: const ExpansionPanelListExample(),
      ),
    );
  }
}

// stores ExpansionPanel state information
class OrderDetails {
  OrderDetails({
    required this.orderGeneratedDate,
    required this.orderValue,
    required this.orderNumber,
    required this.cartId,
    required this.status,
    this.isExpanded = false,
  });

  String orderGeneratedDate;
  String orderValue;
  String orderNumber;
  String cartId;
  String status;
  bool isExpanded;
}

class ExpansionPanelListExample extends StatefulWidget {
  const ExpansionPanelListExample({super.key});

  @override
  State<ExpansionPanelListExample> createState() =>
      _ExpansionPanelListExampleState();
}

class _ExpansionPanelListExampleState extends State<ExpansionPanelListExample> {
  String orderURL = 'http://175.111.182.126:8083/order/v1/customer/1';

  ///
  List<OrderDetails> _data = [];

  Map<String, dynamic> _orderData = {};

  String customerName = '';
  String customerAddressLocality = '';
  String customerAddressCity = '';
  String customerAddressPin = '';
  String customerAddressState = '';
  bool isLoading = false;

  /// On Error Throw callback
  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Something went wrong.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => getOrderList(), // Retry the operation
        ),
        duration:
            const Duration(hours: 1), // Persistent until manually dismissed
      ),
    );
  }

  /// Get Order Details based on Order Number
  Future<void> getOrderDetails(String orderNumber) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8083/order/v1/26801'),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          setState(() {
            _orderData = jsonDecode(response.body);
            customerName = _orderData['customer'] ?? 'Not Provided';
            customerAddressLocality =
                _orderData['shippingAddress']['locality'] ?? 'Unknown';
            customerAddressCity =
                _orderData['shippingAddress']['city'] ?? 'Unknown';
            customerAddressState =
                _orderData['shippingAddress']['state'] ?? 'Unknown';
            customerAddressPin =
                _orderData['shippingAddress']['pincode'] ?? 'Unknown';
            isLoading = false;
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
      SnackbarUtils.showErrorSnackBar(
        context: context,
        message: 'Something went wrong!',
        onRetry: getOrderList,
      );
    }
  }

  /// Get Orders List
  Future<void> getOrderList() async {
    try {
      // Show loading state
      setState(() {
        isLoading = true;
      });

      // API call
      final response = await http.get(Uri.parse(orderURL));

      // Check HTTP status code
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<dynamic> list = jsonDecode(response.body);

          setState(() {
            isLoading = false;
            _data = list.map<OrderDetails>((item) {
              return OrderDetails(
                orderGeneratedDate: item['createdAt'] ?? 'No details provided',
                orderValue: item['customerId'] ?? 'No details provided',
                orderNumber: item['orderNumber'] ?? 'No details provided',
                cartId: item['cartId'] ?? 'No details provided',
                status: item['status'] ?? 'No details provided',
              );
            }).toList();
          });
        }
      } else {
        // Throw an exception for non-success HTTP status codes
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle errors (e.g., network issues, JSON parsing errors)
      setState(() {
        isLoading = false;
      });

      // Show an error message to the user (you can replace this with a custom widget)
      SnackbarUtils.showErrorSnackBar(
        context: context,
        message: 'Something went wrong!',
        onRetry: getOrderList,
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // getOrderDetails();
    getOrderList();
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        // color: Colors.black,
        child: isLoading
            ? Container(
                margin: const EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      dividerColor: Colors.lightGreen,
      animationDuration: const Duration(milliseconds: 500),
      materialGapSize: 2.0,
      expandedHeaderPadding:
          const EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
      elevation: 2,
      expandIconColor: Colors.green,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data.forEach((item) => item.isExpanded = false);
          _data[index].isExpanded = isExpanded;
        });
        if (_data[index].isExpanded) {
          setState(() {
            isLoading = true;
          });
          getOrderDetails(_data[index].orderNumber);
          // print(_data[index].orderNumber);
        }
      },
      children: _data.map<ExpansionPanel>((OrderDetails item) {
        return ExpansionPanel(
          backgroundColor: const Color(0xFF8EB2B2),
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(item.orderGeneratedDate),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.status,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.orderValue),
                          const Icon(
                            Icons.currency_rupee_rounded,
                            size: 19,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            );
          },
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 1.0,
                padding: const EdgeInsets.only(
                    left: 15.0, right: 5.0, top: 5, bottom: 5),
                margin: const EdgeInsets.only(left: 3.0, right: 3.0, bottom: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(customerName, textAlign: TextAlign.start),
                    Text(customerAddressLocality, textAlign: TextAlign.start),
                    Text('$customerAddressCity $customerAddressState',
                        textAlign: TextAlign.start),
                    Text(customerAddressPin, textAlign: TextAlign.start)
                  ],
                ),
              ),

              /// Product List
              ListView.builder(
                itemCount: (_orderData['lineItem'] as List?)?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final productTitle = _orderData['lineItem'][index]
                          ['productName'] ??
                      'Not Provided';
                  final productImage = 'assets/abended_city.png';
                  final productQty = _orderData['lineItem'][index]
                          ['quantity'] ??
                      'Not Provided';
                  final productPrice = _orderData['lineItem'][index]
                          ['productName'] ??
                      'Not Provided';

                  /// Product Container
                  return Container(
                    margin: const EdgeInsets.fromLTRB(3, 0, 3, 2),
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.white.withOpacity(0.7),
                    ),

                    /// Product Details
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Product Image
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            // width: 305,
                            height: 60,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: productImage != null
                                  ? DecorationImage(
                                      image: NetworkImage(productImage),
                                      fit: BoxFit.fill,
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        /// Product Title
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            // color: Colors.brown,
                            child: Text(productTitle),
                          ),
                        ),

                        /// Product Quantity, Price, Total
                        Expanded(
                          flex: 3,
                          child: Container(
                            // color: Colors.brown,
                            child: Text(
                              '$productQty * price = Total price',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
