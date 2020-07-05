import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = '/product-details';

  @override
  Widget build(BuildContext context) {
    final String productId = ModalRoute.of(context).settings.arguments;
    Product selectedProduct =
        Provider.of<Products>(context, listen: false).getById(productId);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(selectedProduct.title),
              background: Hero(
                tag: selectedProduct.id,
                child: Image.network(
                  selectedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '₹${selectedProduct.price}',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 24),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      selectedProduct.description,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
