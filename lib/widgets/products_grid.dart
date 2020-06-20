import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_item.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class ProductsGrid extends StatelessWidget {
  final bool isFavoritesOnly;

  ProductsGrid(this.isFavoritesOnly);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    List<Product> products =
        isFavoritesOnly ? productData.favoritesOnly : productData.items;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(
            // products[index].id,
            // products[index].title,
            // products[index].imageUrl,
            ),
      ),
    );
  }
}
