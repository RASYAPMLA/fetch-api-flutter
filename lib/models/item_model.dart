import 'dart:io';

class ItemModel {
  final int id;
  final String name;
  final int stock;
  final String? imageUrl; // Menampung link gambar dari backend
  final File? localImage; // Menampung gambar dari image picker (untuk preview)

  ItemModel({
    required this.id,
    required this.name,
    required this.stock,
    this.imageUrl,
    this.localImage,
  });

  // Fungsi untuk mem-parsing data JSON dari respons Express.js
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['image'];

    if (rawImageUrl != null) {
      // 1. Ganti localhost menjadi IP Emulator
      rawImageUrl = rawImageUrl.replaceAll('localhost', '192.168.1.4');

      // 2. Koreksi port yang salah dari backend (ganti 3000 ke 5000)
      rawImageUrl = rawImageUrl.replaceAll(':3000', ':5000');
    }

    return ItemModel(
      id: json['id'],
      name: json['name'],
      stock: json['stock'],
      imageUrl: rawImageUrl,
    );
  }
}
