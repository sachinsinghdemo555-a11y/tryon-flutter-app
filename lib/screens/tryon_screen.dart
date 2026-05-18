import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../models/jewellery_product.dart';
import '../services/gemini_service.dart';
import 'camera_screen.dart';
import 'result_screen.dart';

class TryOnScreen extends StatefulWidget {
  final JewelleryProduct product;
  final Uint8List? productImage;
  const TryOnScreen({super.key, required this.product, this.productImage});
  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  Uint8List? _userPhoto;
  bool _isGenerating = false;
  final ImagePicker _picker = ImagePicker();
  final GeminiService _gemini = GeminiService();

  Future<void> _pickFromGallery() async {
    try {
      final XFile? f = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85);
      if (f != null) {
        final b = await f.readAsBytes();
        setState(() => _userPhoto = b);
      }
    } catch (e) {
      _snack('Could not load photo: $e');
    }
  }

  Future<void> _openCameraScreen() async {
    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (result != null) setState(() => _userPhoto = result);
  }

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _handle(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text('Add Your Photo',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: _iconCircle(Icons.camera_alt),
            title: const Text('Take a Selfie',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Live camera with face guide'),
            onTap: () {
              Navigator.pop(context);
              _openCameraScreen();
            },
          ),
          ListTile(
            leading: _iconCircle(Icons.photo_library),
            title: const Text('Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Pick an existing photo'),
            onTap: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Future<void> _generate() async {
    if (_userPhoto == null) return;
    setState(() => _isGenerating = true);
    final result = await _gemini.generateTryOnImage(
      userImage: _userPhoto!, productName: widget.product.name,
      productType: widget.product.type, productDescription: widget.product.description,
      productImage: widget.productImage,
    );
    if (!mounted) return;
    setState(() => _isGenerating = false);
    if (result.isSuccess && result.imageData != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ResultScreen(generatedImage: result.imageData!, productName: widget.product.name, userPhoto: _userPhoto!)));
    } else if (result.isTextOnly) {
      showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text('Gemini Response'),
          content: SingleChildScrollView(child: Text(result.textResponse ?? '')),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
    } else {
      _snack('Error: ${result.errorMessage ?? "Unknown error"}', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg), backgroundColor: isError ? Colors.red : null,
          duration: const Duration(seconds: 5)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.deepPurple,
        foregroundColor: Colors.white,
        title: Text('Your Photo',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Stack(children: [
        Column(children: [
          // Product info card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.goldColor.withOpacity(0.35)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: widget.productImage != null
                      ? Image.memory(widget.productImage!, width: 68, height: 68, fit: BoxFit.cover)
                      : Container(width: 68, height: 68,
                          color: AppConstants.deepPurple.withOpacity(0.08),
                          child: Center(child: Text(widget.product.emoji, style: const TextStyle(fontSize: 36))))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppConstants.deepPurple)),
                const SizedBox(height: 4),
                Text(widget.product.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppConstants.goldColor.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
                  child: Text(widget.product.type.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: AppConstants.darkGold, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ),
              ])),
            ]),
          ),
          // Photo picker
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: _showPhotoSheet,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _userPhoto != null ? AppConstants.deepPurple : Colors.grey.shade300, width: _userPhoto != null ? 2 : 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: _userPhoto != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(fit: StackFit.expand, children: [
                        Image.memory(_userPhoto!, fit: BoxFit.cover),
                        Positioned(bottom: 14, right: 14, child: GestureDetector(
                          onTap: _showPhotoSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(24)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.edit, color: Colors.white, size: 14), SizedBox(width: 5),
                              Text('Change', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ]),
                          ),
                        )),
                      ]))
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(width: 86, height: 86,
                            decoration: BoxDecoration(color: AppConstants.deepPurple.withOpacity(0.09), shape: BoxShape.circle),
                            child: const Icon(Icons.add_a_photo_rounded, size: 42, color: AppConstants.deepPurple)),
                        const SizedBox(height: 18),
                        const Text('Add Your Photo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.deepPurple)),
                        const SizedBox(height: 8),
                        Text('Tap to take a selfie or choose\na photo from your gallery',
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5)),
                        const SizedBox(height: 24),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _chip(Icons.camera_alt, 'Camera'), const SizedBox(width: 12), _chip(Icons.photo_library, 'Gallery'),
                        ]),
                      ]),
              ),
            ),
          )),
          // Generate button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _userPhoto != null && !_isGenerating ? _generate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.goldColor, foregroundColor: Colors.black87,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.auto_awesome, size: 22), const SizedBox(width: 10),
                Text(_userPhoto != null ? 'Generate TryOn' : 'Add your photo first',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            )),
          ),
        ]),
        if (_isGenerating) Container(
          color: Colors.black.withOpacity(0.72),
          child: Center(child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(width: 54, height: 54,
                  child: CircularProgressIndicator(color: AppConstants.deepPurple, strokeWidth: 3)),
              const SizedBox(height: 24),
              const Text('✨ Generating your look…',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppConstants.deepPurple)),
              const SizedBox(height: 8),
              Text('Gemini AI is crafting your\npersonalised try-on',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 6),
              Text('This may take up to 30 seconds', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ]),
          )),
        ),
      ]),
    );
  }

  Widget _handle() => Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)));
  Widget _iconCircle(IconData i) => Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppConstants.deepPurple.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(i, color: AppConstants.deepPurple, size: 20));
  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(color: AppConstants.deepPurple.withOpacity(0.07), borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppConstants.deepPurple.withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: AppConstants.deepPurple), const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: AppConstants.deepPurple, fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );
}
