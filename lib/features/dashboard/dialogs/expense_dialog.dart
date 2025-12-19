import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // [TAMBAHAN] Untuk TextInputFormatter
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // [TAMBAHAN] Untuk NumberFormat
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

  // [UPDATE] Fungsi Pilih Gambar dengan Validasi Ukuran 1 MB & Sumber Dinamis
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source, // Gunakan source yang dipilih (Kamera/Galeri)
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
        );
        print(
          "📸 [DEBUG UI] Ukuran: ${sizeInMb.toStringAsFixed(2)} MB",
        );

        // Jika lolos validasi (<= 1 MB), simpan ke state
        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // [BARU] Fungsi Menampilkan Pilihan (Kamera / Galeri)
  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF4A3AA0)),
                title: const Text('Ambil dari Galeri'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: Color(0xFF4A3AA0)),
                title: const Text('Buka Kamera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
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
        // [PERBAIKAN] Tambahkan SingleChildScrollView agar tidak overflow
        child: SingleChildScrollView(
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
                onTap: () => _showImageSourcePicker(
                    context), // [UPDATE] Panggil picker dialog
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 120, // Tinggi area upload
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    // Membuat border solid
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
                              "Max 1 MB files are allowed",
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
                // [TAMBAHAN] Agar input mulai dari kanan
                textAlign: TextAlign.center,
                // [PERBAIKAN] Warna teks input hitam
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
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
                // [TAMBAHAN] Agar input mulai dari kanan
                textAlign: TextAlign.center,
                // [TAMBAHAN] Formatter Rupiah
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                // [PERBAIKAN] Warna teks input hitam
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
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
                          backgroundColor: Colors.red,
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
                          backgroundColor:
                              kBrandColor, // Warna Ungu
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          print(
                            "🖱️ [DEBUG UI] Tombol Save Ditekan",
                          );
                          print(
                            "📝 [DEBUG UI] Desc: ${_descController.text}, Amount: ${_amountController.text}, Path: ${_selectedImage?.path}",
                          );
                          // Kirim data balik ke parent via callback
                          widget.onSave(
                            _descController.text,
                            _amountController.text,
                            _selectedImage
                                ?.path, // Kirim path gambar (bisa null)
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
      ),
    );
  }
}

// ================= [TAMBAHAN CLASS FORMATTER] =================

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(
      newValue.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ', // Symbol Rupiah
      decimalDigits: 0,
    );

    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}