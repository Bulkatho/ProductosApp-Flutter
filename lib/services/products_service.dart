
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;


class ProductsService extends ChangeNotifier {

  final String _baseUrl = 'flutter-varios-dfbb0-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  Product? selectedProduct;

  bool isLoading = true;
  bool isSaving = false;

  ProductsService(){
    loadProducts();
  }

  
  Future<List<Product>> loadProducts() async{
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);
    
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });
    
    isLoading = false;
    notifyListeners();
    
    return products;
  }

  Future saveOrCreateProduct(Product product) async{
    isSaving = true;
    notifyListeners();

    if(product.id == null){
      //Insert - crear
    } else {
      //Actualizar
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();

  }

  Future<String> updateProduct(Product product) async{
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put( url, body: product.toJson() );

    final decodedData = resp.body;
    //Actualiza listado de productos.
    final index = products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }
}