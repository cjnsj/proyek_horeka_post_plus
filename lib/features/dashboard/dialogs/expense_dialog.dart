import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:horeka_post_plus/features/dashboard/view/dashboard_constants.dart';

class ExpenseDialog extends StatefulWidget {
  const ExpenseDialog({super.key, required this.onSave});

  // Update callback untuk menerima imagePath
  final Function(String desc, String amount, String? imagePath) onSave;

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();

  // Variabel untuk menyimpan gambar yang dipilih
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // [UPDATE] Fungsi Pilih Gambar dengan Validasi Ukuran 1 MB
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompresi kualitas (opsional)
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Hitung ukuran file dalam Bytes
      int sizeInBytes = await imageFile.length();
      double sizeInMb = sizeInBytes / (1024 * 1024); // Konversi ke MB

      // [VALIDASI] Jika lebih dari 1 MB, tolak!
      if (sizeInMb > 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran gambar terlalu besar! Maksimal 1 MB.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        // Jangan simpan file ke state, langsung keluar
        return;
      }
      print(
        "📸 [DEBUG UI] Gambar dipilih: ${pickedFile.path}",
      ); // <--- TAMBAH INI
      print(
        "📸 [DEBUG UI] Ukuran: ${sizeInMb.toStringAsFixed(2)} MB",
      ); // <--- TAMBAH INI

      // Jika lolos validasi (<= 1 MB), simpan ke state
      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 450, // Lebar disesuaikan
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. UPLOAD IMAGE SECTION ---
            const Text(
              "Upload Image Proof :",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120, // Tinggi area upload
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // Membuat border solid (bisa diganti package dotted_border jika ingin putus-putus)
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Max 1 MB files are allowed", // [UPDATE] Teks sesuai logika
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. DESCRIPTION ---
            const Text(
              "Description :",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kBrandColor),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. AMOUNT ---
            const Text(
              "Amount of expenditure (Rp) :",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kBrandColor),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- 4. BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A3AA0), // Warna Ungu
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        print(
                          "🖱️ [DEBUG UI] Tombol Save Ditekan",
                        ); // <--- TAMBAH INI
                        print(
                          "📝 [DEBUG UI] Desc: ${_descController.text}, Amount: ${_amountController.text}, Path: ${_selectedImage?.path}",
                        ); // <--- TAMBAH INI
                        // Kirim data balik ke parent via callback
                        widget.onSave(
                          _descController.text,
                          _amountController.text,
                          _selectedImage?.path, // Kirim path gambar (bisa null)
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
