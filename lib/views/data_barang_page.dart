import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_apps/widgets/form/build_text_field.dart';

class DataBarangPage extends StatefulWidget {
  const DataBarangPage({super.key});
  @override
  State<DataBarangPage> createState() => _DataBarangPageState();
}

class _DataBarangPageState extends State<DataBarangPage> {
  final List<Map<String, dynamic>> _barangList = [
    {'id': 1, 'nama': 'Laptop Dell XPS 15', 'stok': 8, 'image': null},
    {'id': 2, 'nama': 'Proyektor Epson EB-X51', 'stok': 3, 'image': null},
    {'id': 3, 'nama': 'Kamera Canon EOS M50', 'stok': 5, 'image': null},
    {'id': 4, 'nama': 'Tripod Profesional', 'stok': 10, 'image': null},
    {'id': 5, 'nama': 'Mic Wireless Boya', 'stok': 6, 'image': null},
    {'id': 6, 'nama': 'Speaker JBL Portable', 'stok': 4, 'image': null},
    {'id': 7, 'nama': 'Whiteboard 120x240', 'stok': 2, 'image': null},
    {'id': 8, 'nama': 'Mouse Logitech MX', 'stok': 12, 'image': null},
  ];

  final ImagePicker _picker = ImagePicker();

  /// Menampilkan form bottom sheet untuk tambah atau edit barang
  void _showBarangFormDialog({Map<String, dynamic>? barang}) {
    final isEdit = barang != null;
    final namaController = TextEditingController(text: barang?['nama'] ?? '');
    final stokController = TextEditingController(
      text: barang?['stok']?.toString() ?? '',
    );
    File? selectedImage = barang?['image'];
    final formKey = GlobalKey<FormState>();

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

                  // Nama Barang (Wajib)
                  buildTextField(
                    namaController,
                    'Nama Barang *',
                    Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 14),

                  // Stok (Wajib)
                  buildTextField(
                    stokController,
                    'Jumlah Stok *',
                    Icons.numbers,
                    isNumber: true,
                  ),
                  const SizedBox(height: 14),

                  // Image Picker (Wajib)
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setModalState(() {
                          selectedImage = File(image.path);
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
                          color: selectedImage != null
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: selectedImage != null ? 2 : 1,
                        ),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
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
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Pilih Gambar dari Galeri *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'JPG, PNG (Maks 1MB)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validasi semua field wajib
                        if (namaController.text.trim().isEmpty) {
                          _showValidationSnackBar(
                            bottomSheetContext,
                            'Nama barang wajib diisi!',
                          );
                          return;
                        }
                        if (stokController.text.trim().isEmpty ||
                            int.tryParse(stokController.text.trim()) == null) {
                          _showValidationSnackBar(
                            bottomSheetContext,
                            'Jumlah stok wajib diisi dengan angka!',
                          );
                          return;
                        }
                        if (selectedImage == null && !isEdit) {
                          _showValidationSnackBar(
                            bottomSheetContext,
                            'Gambar wajib dipilih!',
                          );
                          return;
                        }

                        setState(() {
                          if (isEdit) {
                            final index = _barangList.indexWhere(
                              (item) => item['id'] == barang['id'],
                            );
                            if (index != -1) {
                              _barangList[index] = {
                                'id': barang['id'],
                                'nama': namaController.text.trim(),
                                'stok':
                                    int.tryParse(stokController.text.trim()) ??
                                    0,
                                'image':
                                    selectedImage ?? barang['image'],
                              };
                            }
                          } else {
                            _barangList.add({
                              'id': _barangList.length + 1,
                              'nama': namaController.text.trim(),
                              'stok':
                                  int.tryParse(stokController.text.trim()) ?? 0,
                              'image': selectedImage,
                            });
                          }
                        });
                        Navigator.pop(bottomSheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                        style: const TextStyle(
                          fontSize: 15,
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

  /// Menampilkan snackbar validasi di dalam bottom sheet
  void _showValidationSnackBar(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Menampilkan dialog konfirmasi untuk menghapus barang
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
            onPressed: () {
              setState(
                () => _barangList.removeWhere((item) => item['id'] == id),
              );
              Navigator.pop(dialogContext);
            },
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
            // AppBar
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
                      '${_barangList.length} item',
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
            // Search
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
            // List Barang
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: _barangList.length,
                itemBuilder: (_, index) {
                  final barang = _barangList[index];
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
                              gradient: barang['image'] == null
                                  ? LinearGradient(
                                      colors: [
                                        const Color(0xFFEFF6FF),
                                        const Color(0xFFDBEAFE),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: barang['image'] != null
                                ? Image.file(
                                    barang['image'] as File,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  )
                                : Icon(
                                    Icons.inventory_2_rounded,
                                    color: const Color(0xFF2563EB),
                                    size: 24,
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  barang['nama'],
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
                                      'Stok: ${barang['stok']}',
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
                          const SizedBox(height: 8),
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
                                () => _showHapusBarangDialog(barang['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  /// Tombol aksi kecil (edit/delete) di setiap item card
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
