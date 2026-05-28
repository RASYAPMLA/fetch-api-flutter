import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_apps/models/item_model.dart';
import 'package:inventory_apps/widgets/form/build_text_field.dart';
import 'package:inventory_apps/service/item_service.dart';

class DataBarangPage extends StatefulWidget {
  const DataBarangPage({super.key});

  @override
  State<DataBarangPage> createState() => _DataBarangPageState();
}

class _DataBarangPageState extends State<DataBarangPage> {
  final ImagePicker _picker = ImagePicker();
  final ItemService _apiService = ItemService(); // ✅ fix typo

  late Future<List<ItemModel>> _itemsFuture;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // ==========================================
  // FUNGSI GET (BACA DATA)
  // ==========================================
  void _refreshData() {
    setState(() {
      _itemsFuture = _apiService.getItems().then((items) {
        setState(() => _totalItems = items.length);
        return items;
      });
    });
  }

  // ==========================================
  // SNACKBAR UMUM (sukses & error)
  // ==========================================
  void _showSnackBar(BuildContext ctx, String message, {bool isError = true}) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // FUNGSI DELETE (HAPUS DATA)
  // ==========================================
  Future<void> _prosesHapus(int id, BuildContext dialogContext) async {
    Navigator.pop(dialogContext);

    try {
      await _apiService.deleteItem(id);
      if (mounted) {
        _showSnackBar(context, 'Barang berhasil dihapus!', isError: false);
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, 'Gagal menghapus: $e', isError: true);
      }
    }
  }

  // ==========================================
  // DIALOG FORM CREATE & UPDATE
  // ==========================================
  void _showBarangFormDialog({ItemModel? barang}) {
    final isEdit = barang != null;
    final namaController = TextEditingController(text: barang?.name ?? '');
    final stokController = TextEditingController(
      text: barang?.stock.toString() ?? '',
    );
    File? selectedImage = barang?.localImage;
    Uint8List? selectedImageBytes;
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (bottomSheetContext, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEdit ? 'Edit Barang' : 'Tambah Barang',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  buildTextField(
                    namaController,
                    'Nama Barang *',
                    Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 14),

                  buildTextField(
                    stokController,
                    'Jumlah Stok *',
                    Icons.numbers,
                    isNumber: true,
                  ),
                  const SizedBox(height: 14),

                  // Image Picker
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setModalState(() {
                          selectedImage = kIsWeb ? null : File(image.path);
                          selectedImageBytes = bytes;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedImageBytes != null
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: selectedImageBytes != null ? 2 : 1,
                        ),
                      ),
                      child: selectedImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  kIsWeb
                                      ? Image.memory(
                                          selectedImageBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Color(0xFF2563EB),
                                  size: 24,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pilih Gambar dari Galeri *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // TOMBOL EKSEKUSI POST / PUT
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (namaController.text.trim().isEmpty ||
                                  stokController.text.trim().isEmpty) {
                                _showSnackBar(
                                  bottomSheetContext,
                                  'Lengkapi form!',
                                  isError: true,
                                );
                                return;
                              }
                              // ✅ cek selectedImageBytes untuk support web
                              if (selectedImageBytes == null && !isEdit) {
                                _showSnackBar(
                                  bottomSheetContext,
                                  'Gambar wajib dipilih!',
                                  isError: true,
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              try {
                                if (isEdit) {
                                  // EKSEKUSI UPDATE (PUT)
                                  await _apiService.updateItem(
                                    id: barang.id,
                                    name: namaController.text.trim(),
                                    stock: stokController.text.trim(),
                                    newImageFile:
                                        selectedImage != barang.localImage
                                            ? selectedImage
                                            : null,
                                  );
                                } else {
                                  // EKSEKUSI CREATE (POST)
                                  await _apiService.createItem(
                                    name: namaController.text.trim(),
                                    stock: stokController.text.trim(),
                                    imageFile: selectedImage!,
                                  );
                                }

                                if (mounted) {
                                  Navigator.pop(bottomSheetContext);
                                  _showSnackBar(
                                    context,
                                    isEdit
                                        ? 'Berhasil diperbarui!'
                                        : 'Berhasil ditambahkan!',
                                    isError: false,
                                  );
                                  _refreshData();
                                }
                              } catch (e) {
                                if (mounted) {
                                  _showSnackBar(
                                    bottomSheetContext,
                                    e.toString(),
                                    isError: true,
                                  );
                                }
                              } finally {
                                setModalState(() => isSubmitting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DIALOG KONFIRMASI HAPUS
  // ==========================================
  void _showHapusBarangDialog(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          'Hapus Barang',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () => _prosesHapus(id, dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // APP BAR
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Data Barang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_totalItems item',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // SEARCH BAR
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari barang...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // ==========================================
            // LIST BARANG — FutureBuilder
            // ==========================================
            Expanded(
              child: FutureBuilder<List<ItemModel>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada data barang',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    );
                  }

                  final items = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: _totalItems,
                    itemBuilder: (_, index) {
                      final barang = items[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Thumbnail gambar barang
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: barang.imageUrl != null
                                    ? Image.network(
                                        barang.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2_rounded,
                                        color: Color(0xFF2563EB),
                                        size: 24,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      barang.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const SizedBox(width: 3),
                                        const Icon(
                                          Icons.layers_outlined,
                                          size: 14,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Stok: ${barang.stock}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildActionButton(
                                    Icons.edit_rounded,
                                    const Color(0xFFF59E0B),
                                    () => _showBarangFormDialog(barang: barang),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildActionButton(
                                    Icons.delete_rounded,
                                    const Color(0xFFEF4444),
                                    () => _showHapusBarangDialog(barang.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBarangFormDialog(),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}