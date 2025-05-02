import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/models/product.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  Stream<QuerySnapshot> getProductsStream() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('제품 목록')),
      body: StreamBuilder<QuerySnapshot>(
          stream: getProductsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('오류 발생'));
            }

            final docs = snapshot.data!.docs;

            if(docs.isEmpty) {
              return const Center(child: Text('현재 제품이 없습니다.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index){
                final data = docs[index].data() as Map<String, dynamic>;
                return ProductCard(data: data);
              }
            );
          }
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final product = Product(id: data['id'],
        imageTitle: ImageTitle.values.firstWhere((e) =>
          e.toString().split('.').last == data['imageTitle']),
        category: ProductCategory.values.firstWhere((e) =>
          e.toString().split('.').last == data['category']),
        cost: (data['cost'] as num).toDouble(),
        title: data['title']);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: product.imageTitle != null
            ? Image.asset(product.imageUrl, width: 50, height: 50,
                      fit: BoxFit.cover)
            : const Icon(Icons.image_not_supported),
        title: Text(product.title ?? '없는 제품명'),
        subtitle: Text('${product.category.toString().split('.').last} - ${product.cost}원'),
        trailing: const Icon(Icons.chevron_right),
        )
      );
  }

}
