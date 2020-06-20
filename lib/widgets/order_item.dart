import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as op;

class OrderItem extends StatefulWidget {
  final op.OrderItem orderItem;

  OrderItem(this.orderItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              '₹${widget.orderItem.amount}',
            ),
            subtitle: Text(DateFormat("dd/MM/yyyy HH:mm")
                .format(widget.orderItem.dateTime)),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          // if (_isExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            height: min(widget.orderItem.products.length * 30.0 + 10, 200),
            child: ListView(
              children: widget.orderItem.products
                  .map((item) => Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              item.product.title,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${item.quantity}x ₹${item.product.price}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
