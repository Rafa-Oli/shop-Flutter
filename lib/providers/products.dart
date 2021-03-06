import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/utils/constants.dart';
import 'product.dart';

class Products with ChangeNotifier {
  final String _baseUrl = '${Constants.BASE_API_URL}/products';

  //observable, vai notificar mudanças
  List<Product> _items = [];
  String _token;
  String _userId;

  Products([this._token, this._items = const [], this._userId]);

// vai retornar a copia dos dados, para que não tenha perca o controle dos dados
  List<Product> get items => [..._items];

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadProducts() async {
    final response = await http.get("$_baseUrl.json?auth=$_token");
    Map<String, dynamic> data = json.decode(response.body);

    final favResponse = await http.get(
        "${Constants.BASE_API_URL}/userFavorites/$_userId.json?auth=$_token");
    final favMap = json.decode(favResponse.body);

    _items.clear();

    if (data != null) {
      data.forEach((productId, productData) {
        final isfavorite = favMap == null ? false : favMap[productId] ?? false;
        _items.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isfavorite,
        ));
      });
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> addProduct(Product newProduct) async {
    final response = await http.post(
      "$_baseUrl.json?auth=$_token",
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
      }),
    );
    _items.add(Product(
      id: json.decode(response.body)['name'],
      title: newProduct.title,
      description: newProduct.description,
      price: newProduct.price,
      imageUrl: newProduct.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }
    //retorna o index
    final index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      await http.patch(
        "$_baseUrl/${product.id}.json?auth=$_token",
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final product = _items[index];
      //remove produto localmente
      _items.remove(product);
      notifyListeners();

      //excluindo no fire
      final response =
          await http.delete("$_baseUrl/${product.id}.json?auth=$_token");

      if (response.statusCode >= 400) {
        //se der erro, insere novamente
        _items.insert(index, product);
        notifyListeners();
        throw HttpException("Ocorreu um erro na exclusão do produto.");
      }
    }
  }
}
