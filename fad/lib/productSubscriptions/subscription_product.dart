
import 'dart:convert';

import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(const ProductSubscriptionsPage());
}



class ProductSubscriptionsPage extends StatefulWidget {
  const ProductSubscriptionsPage({super.key});

  @override
  State<ProductSubscriptionsPage> createState() => ProductSubscriptionsState();
}


class ProductSubscriptionsState extends State<ProductSubscriptionsPage> {

  ///
  final SessionManager _sessionManager = SessionManager();
  final baseUrl = 'http://175.111.182.125';

  ///
  List<dynamic> _productList = [];
  bool _isLoading = false;
  String _userId = '';
  bool _productEdit = false;
  DateTime? _selectedDate;

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

  void getUserId() async {
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
  }


  /// Get All Products
  Future<void> getProducts() async {

    setState(() {
      _isLoading = true;
    });// set _isLoading

    try {
      final response = await http.get(
        Uri.parse('$baseUrl:8081/product/v1/products'),
        headers: {
          'Authorization': 'Bearer',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          setState(() {
            _isLoading = false;
            _productList = jsonDecode((response.body));
          });

        } else {
          throw('Products not found!');
        }
      } else {
        print('Something went wrong!');
        throw('Something went wrong!');
      }
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      _showErrorSnackBar(e.toString());
    }
  }

  /// pick date
  Future<void> pickDate() async {
    final DateTime? pickedDate = await showDatePicker(

      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue, // Header background color
                onPrimary: Colors.white, // Header text color
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                )
              )
            ),
            child: child!,
        );
      }
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }


  ///
  Future<void> _refreshPage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    getProducts(); // Fetch data again when the page is refreshed
    print('object');
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(),
     backgroundColor: const Color(0xFF7AB2B2),
     body: RefreshIndicator(
       onRefresh: _refreshPage,
       child: _isLoading ?
         const Center(child: CircularProgressIndicator(),)
         : _productList.isEmpty ? ListView.builder(itemCount: 1, itemBuilder: (BuildContext context, int index) { return Container(height: 300, alignment: Alignment.center, child: const Text('There is nothing to show. '),); },)
           : ListView.builder(
              shrinkWrap: true,
              itemCount: _productList.length,
              itemBuilder: (context, index) {
                final productTitle = _productList[index]['name'] ?? 'Unknown';
                final productImage = 'assets/milk.jpg';
                final productPrice = _productList[index]['price']['price'] ?? 'Unknown';
                final productQty = '1';
                final productUnit = _productList[index]['price']['unit'] ?? 'Unknown';
                final productCreatedDate = _productList[index] ?? 'Unknown';
                final productStatus = _productList[index]['price']['status'] ?? 'Unknown';

                ///
                return Card(
                  color: Colors.white.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        /// Order created date, status and 3 dots menu (opens bottom sheet)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            /// Order created date
                            const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 0, left: 5, right: 0,),
                                  child: Text(
                                    'Order created: 12/02/2025',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ),

                            /// Product status
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$productStatus',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            /// 3 dots menu (opens bottom sheet)
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.edit, color: Colors.blue),
                                            title: const Text('Edit'),
                                            onTap: () {
                                              setState(() {
                                                _productEdit = true;
                                              });
                                              Navigator.pop(context);
                                              print("Edit clicked");
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.play_circle_outline, color: Colors.yellow),
                                            title: const Text('Pause'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              print("Pause clicked");
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.cancel, color: Colors.red),
                                            title: const Text('Cancel'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              print("Share Cancel");
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),


                        /// Product image, title, quantity, unit, price and quantity increase & decrease buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            /// Product image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage(productImage),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),

                            /// Product title
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '$productTitle',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            /// Product quantity, unit and quantity increase & decrease buttons
                            Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    /// icon to decease product quantity
                                    if (_productEdit)
                                      IconButton(
                                          onPressed: (){},
                                          color: Colors.red,
                                          icon: const Icon(
                                            Icons.remove_circle,
                                          )
                                      ),

                                    /// Product quantity and unit
                                    Text(
                                      '$productQty $productUnit',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),

                                    /// icon to increase product quantity
                                    if (_productEdit)
                                      IconButton(
                                          onPressed: (){},
                                          color: Colors.green,
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          )
                                      ),
                                  ],
                                )
                            ),

                            /// Product price
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
                                  child:  Text(
                                    '₹$productPrice',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                )
                            ),
                          ],
                        ),

                        /// Product Delivery frequency
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 8, top: 15,),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.lightBlueAccent,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Everyday',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        /// last updated date and calender to change the date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                           /// Last updated date
                           Expanded(
                             child: Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                               child: Text(
                                 _selectedDate != null
                                  ? 'Last update: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Last update: 00/00/00',
                                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                               ),
                             ),
                           ),

                           /// Date picker
                            if (_productEdit)
                             Expanded(
                               child: Padding(
                                 padding: const EdgeInsets.only(),
                                 child: IconButton(
                                     onPressed: pickDate,
                                     icon: const Icon(Icons.calendar_month_outlined),
                                 ),
                               ),
                             ),
                         ],
                       )
                      ],
                    ),
                  ),
                );
              }
       ),
     ),
   );
  }
}