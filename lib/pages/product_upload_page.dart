import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/utils/product_seeds.dart';
import 'package:e_commerce/utils/uuid.dart';
import "package:e_commerce/models/product.dart";
import 'package:e_commerce/pages/product_list_page.dart';

class ProductUploadPage extends StatefulWidget {

  const ProductUploadPage({super.key});

  @override
  State<StatefulWidget> createState() {

    return _ProductUploadPageState();
  }
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final _formKey = GlobalKey<FormState>(); // 폼키
  final _titleController = TextEditingController(); //제품명컨트롤러
  final _costController = TextEditingController(); // 가격컨트롤러
  ProductCategory? _selectedCategory; //선택된 카테고리
  ImageTitle? _selectedImage; // 선택된 이미지

  void _goToProductList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductListPage()),
    );
  }

  Future<void> _saveProduct() async {
    if(_formKey.currentState!.validate()){
      final product = Product(
        id: Uuid().generateV4(),
        title: _titleController.text,
        cost: double.tryParse(_costController.text),
        category: _selectedCategory,
        imageTitle: _selectedImage
      );

      await FirebaseFirestore.instance.collection('products')
          .doc(product.id).set({
        'id': product.id,
        'title': product.title,
        'cost': product.cost,
        'category': product.category.toString().split('.').last,
        'imageTitle': product.imageTitle.toString().split('.').last
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제품 등록 완료!'))
      );

      _formKey.currentState?.reset();

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 등록')),
      body: Padding(padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '제품명'),
                  validator: (value) => value!.isEmpty ? '제품명을 입력하세요' : null
              ),
              TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '가격'),
                  validator: (value) => value!.isEmpty ? '가격을 입력하세요' : null
              ),
              DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: '카테고리'),
                  value: _selectedCategory,
                  items: ProductCategory.values.map((category){
                    return DropdownMenuItem(
                        value: category,
                        child: Text(category.toString().split('.').last));
                  }).toList(),
                  onChanged: (val) => setState(() {
                    _selectedCategory = val;
                  })),
              DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: '이미지'),
                  value: _selectedImage,
                  items: ImageTitle.values.map((image){
                    return DropdownMenuItem(
                        value: image,
                        child: Text(image.toString().split('.').last));
                  }).toList(),
                  onChanged: (val) => setState(() {
                    _selectedImage = val;
                  })),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('제품 저장')),
              ElevatedButton(
                  onPressed: _goToProductList,
                  child: const Text('제품목록'))
            ],
          ),)
        )


    );
  }
}

