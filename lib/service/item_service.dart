import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_apps/config/api_config.dart';
import 'package:inventory_apps/models/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token') ?? '';

    return {
      'Authorization': token,
    };
  }

  Future<List<ItemModel>> getItems() async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/items',
    );

    final headers = await _getHeaders();

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(
          response.body,
        );

        final List data =
            responseData['data'] ?? [];

        return data.map((e) {
          return ItemModel.fromJson(e);
        }).toList();
      } else {
        throw Exception(
          'Gagal mengambil data',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ItemModel> createItem({
    required String name,
    required String stock,
    required File imageFile,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/items',
    );

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    final prefs = await SharedPreferences.getInstance();

    final token =
        prefs.getString('token') ?? '';

    request.headers['Authorization'] =
        token;

    request.fields['name'] = name;
    request.fields['stock'] = stock;

    if (!kIsWeb) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
    }

    try {
      final streamedResponse =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final responseData = json.decode(
          response.body,
        );

        return ItemModel.fromJson(
          responseData['data'],
        );
      } else {
        throw Exception(
          'Gagal tambah barang',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ItemModel> updateItem({
    required int id,
    required String name,
    required String stock,
    File? newImageFile,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/items/$id',
    );

    final request = http.MultipartRequest(
      'PUT',
      url,
    );

    final prefs = await SharedPreferences.getInstance();

    final token =
        prefs.getString('token') ?? '';

    request.headers['Authorization'] =
        token;

    request.fields['name'] = name;
    request.fields['stock'] = stock;

    if (newImageFile != null &&
        !kIsWeb) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          newImageFile.path,
        ),
      );
    }

    try {
      final streamedResponse =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(
          response.body,
        );

        return ItemModel.fromJson(
          responseData['data'],
        );
      } else {
        throw Exception(
          'Gagal update barang',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> deleteItem(
    int id,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/items/$id',
    );

    final headers = await _getHeaders();

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          'Gagal hapus barang',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}