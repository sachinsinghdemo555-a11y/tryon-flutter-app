import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../models/jewellery_product.dart';
import 'tryon_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});
  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen>
    with SingleTickerProviderStateMixin {
  JewelleryProduct? _selected;
  Uint8List? _customImage;
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  final List<_Tab> _tabs = const [
    _Tab('✨ Sets',      JewelleryCategory.sets),
    _Tab('📿 Necklaces', JewelleryCategory.necklaces),
    _Tab('👂 Earrings',  JewelleryCategory.earrings),
    _Tab('💍 Rings',     JewelleryCategory.rings),
    _Tab('🟡 Bangles',   JewelleryCategory.bangles),
    _Tab('📸 Custom',    JewelleryCategory.custom),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<JewelleryProduct> _productsFor(JewelleryCategory cat) =>
      JewelleryProduct.predefinedProducts.where((p) => p.category == cat).toList();

  Future<void> _pickProductImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
          source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() => _customImage = bytes);
      }
    } catch (e) {
      _snack('Could not load image: $e');
    }
  }

  void _showProductImageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _handle(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text('Upload Your Jewellery',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: _iconCircle(Icons.camera_alt),
            title: const Text('Take a Photo',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Use your camera'),
            onTap: () {
              Navigator.pop(context);
              _pickProductImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: _iconCircle(Icons.photo_library),
            title: const Text('Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Pick an existing image'),
            onTap: () {
              Navigator.pop(context);
              _pickProductImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _proceed() {
    if (_selected == null) return;
    if (_selected!.isCustom && _customImage == null) {
      _snack('Please upload a jewellery image first.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TryOnScreen(
          product: _selected!,
          productImage: _customImage,
        ),
      ),
    );
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.deepPurple,
        foregroundColor: Colors.white,
        title: Text('Select Jewellery',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppConstants.goldColor,
          indicatorWeight: 3,
          labelColor: AppConstants.goldColor,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: Column(children: [
        // Hint banner
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: AppConstants.deepPurple.withOpacity(0.06),
          child: Text(
            'Choose from our catalogue or tap "Custom" to upload your own piece.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((t) => _buildGrid(_productsFor(t.category))).toList(),
          ),
        ),
        // Bottom CTA
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected != null ? _proceed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.deepPurple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _selected != null
                        ? 'Try On: ${_selected!.name}'
                        : 'Select a Jewellery Piece',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildGrid(List<JewelleryProduct> products) {
    if (products.isEmpty) {
      return const Center(
          child: Text('No products in this category.',
              style: TextStyle(color: Colors.grey)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.78),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        isSelected: _selected?.id == products[i].id,
        customImage: products[i].isCustom ? _customImage : null,
        onTap: () {
          setState(() {
            _selected = products[i];
            if (!products[i].isCustom) _customImage = null;
          });
          if (products[i].isCustom) _showProductImageSheet();
        },
      ),
    );
  }

  Widget _handle() => Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2)),
      );

  Widget _iconCircle(IconData i) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppConstants.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle),
        child: Icon(i, color: AppConstants.deepPurple, size: 20),
      );
}

// ── Private card widget ────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final JewelleryProduct product;
  final bool isSelected;
  final Uint8List? customImage;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
    this.customImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.deepPurple.withOpacity(0.09)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppConstants.deepPurple
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Stack(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Thumbnail ──────────────────────────────────────────
                  if (product.isCustom && customImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(customImage!,
                          width: 54, height: 54, fit: BoxFit.cover),
                    )
                  else
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Text(product.emoji,
                            style: const TextStyle(fontSize: 36)),
                        if (product.isFullSet)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppConstants.goldColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('SET',
                                style: TextStyle(
                                    fontSize: 7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  const SizedBox(height: 7),
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppConstants.deepPurple
                          : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: AppConstants.deepPurple,
                    shape: BoxShape.circle),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 12),
              ),
            ),
        ]),
      ),
    );
  }
}

class _Tab {
  final String label;
  final JewelleryCategory category;
  const _Tab(this.label, this.category);
}
