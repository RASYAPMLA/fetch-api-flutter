import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inventory_apps/models/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_apps/config/api_config.dart'; // Sesuaikan path ini

class ItemService {
  // Fungsi internal untuk mengambil token dari SharedPreferences
  // dan merakit header secara otomatis
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('token') ?? ''; // Ambil token, kosongkan jika tidak ada

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ==========================================
  // 1. GET ALL ITEMS (Read)
  // ==========================================
  Future<List<ItemModel>> getItems() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');

    // Ambil header yang sudah berisi Bearer token terbaru
    final headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> dataList = responseData['data'] ?? [];

        return dataList.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  // ==========================================
  // 2. CREATE ITEM (Post dengan Image)
  // ==========================================
  Future<ItemModel> createItem({
    required String name,
    required String stock,
    required File imageFile,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items');
    var request = http.MultipartRequest('POST', url);

    // Ambil token secara manual untuk Multipart Request
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['stock'] = stock;
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ItemModel.fromJson(responseData['data']);
      } else {
        throw Exception('Gagal menyimpan barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  // ==========================================
  // 3. UPDATE ITEM (Put/Patch dengan Image Opsional)
  // ==========================================
  Future<ItemModel> updateItem({
    required int id,
    required String name,
    required String stock,
    File? newImageFile,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items/$id');
    var request = http.MultipartRequest('PUT', url);

    // Ambil token secara manual untuk Multipart Request
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['stock'] = stock;

    if (newImageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', newImageFile.path),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ItemModel.fromJson(responseData['data']);
      } else {
        throw Exception('Gagal memperbarui barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  // ==========================================
  // 4. DELETE ITEM (Delete)
  // ==========================================
  Future<bool> deleteItem(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/items/$id');
    final headers = await _getHeaders();

    http.Response response;

    // 1. TRY-CATCH KHUSUS UNTUK KONEKSI INTERNET MATI / TIMEOUT
    try {
      response = await http.delete(url, headers: headers);
    } catch (e) {
      throw Exception(
        'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      );
    }

    // 2. CEK STATUS CODE DI LUAR TRY-CATCH
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; // Sukses
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);

      if (responseData['message'] == 'Item is already related to a loan') {
        throw Exception(
          'Barang tidak bisa dihapus karena sedang dalam masa peminjaman.',
        );
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menghapus barang.');
      }
    } else {
      throw Exception(
        'Terjadi kesalahan pada server (Error: ${response.statusCode})',
      );
    }
  }
}
