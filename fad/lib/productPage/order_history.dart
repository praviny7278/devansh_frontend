import 'dart:convert';

import 'package:fad/productPage/order_list_item_history.dart';
import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/error_throw_widget.dart';

void main() => runApp(const OrderList());

class OrderList extends StatelessWidget {
  const OrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF7AB2B2),
        appBar: AppBar(
          title: const Text('Order History'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: const OrderHistoryList(),
      ),
    );
  }
}


class OrderHistoryList extends StatefulWidget {
  const OrderHistoryList({super.key});

  @override
  State<OrderHistoryList> createState() =>
      _OrderHistoryListState();
}

class _OrderHistoryListState extends State<OrderHistoryList> {

  final SessionManager _sessionManager = SessionManager();



  ///
  List<dynamic> _orderData = [];

  bool _isLoading = false;
  String _userId = '';

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

  /// Get User Id
  Future<void> getUserId() async {

    try {
      String? id = await _sessionManager.getUserId();


      if ( id != null && id.isNotEmpty) {
        setState(() {
          _userId = id;
        });
        getOrderList();
        print('id : $_userId');
      } else {
        throw ('User id not found!');
      }
    } catch(e) {
      print(e);
    }
    // print(accessToken);
  }

  /// Get Orders List
  Future<void> getOrderList() async {
    final String orderURL = 'http://175.111.182.125:8083/order/v1/customer/$_userId';
    print('user Id: $_userId');

    try {
      // Show loading state
      setState(() {
        _isLoading = true;
      });
      // API call
      final response = await http.get(Uri.parse(orderURL));
      // Check HTTP status code
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          setState(() {
            _isLoading = false;
            _orderData = jsonDecode(response.body);
          });
        }
      } else {
        // Throw an exception for non-success HTTP status codes
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle errors (e.g., network issues, JSON parsing errors)
      setState(() {
        _isLoading = false;
      });
      print(error);

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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // getOrderDetails();
    getUserId();

    // getOrderList();
    setState(() {
      _isLoading = true;
    });
  }



  @override
  Widget build(BuildContext context) {
    return  Container(
        // child: _buildPanel(),
        child: _isLoading
            ? Container(
                margin: const EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : _buildPanel(),
    );
  }

  Widget _buildPanel() {
    return ListView.builder(
      itemCount: _orderData.length,
      itemBuilder: (context, index) {
        final orderNumber = _orderData[index]['orderNumber']?? 'Unknown';
        final orderStatus = _orderData[index]['status']?? 'Unknown';
        final orderDate = _orderData[index]['createdAt']?? 'Unknown';
        // final orderNumber = _orderData[index]['']?? 'Unknown';
        // print(_orderData);
        return GestureDetector(
          onTap: () {
            String value = orderNumber.replaceAll("#", "");

            Navigator.push(context, MaterialPageRoute(builder: (context) => OrderItemListPage(orderNumber: value, orderPlacedDate: orderDate)));
          },
          child: Container(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
            margin: const EdgeInsets.only(top: 1, left: 2, right: 2, bottom: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.white.withOpacity(0.7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('$orderNumber',
                      style: const TextStyle(
                          fontSize: 13,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text('$orderStatus',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('$orderDate'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
