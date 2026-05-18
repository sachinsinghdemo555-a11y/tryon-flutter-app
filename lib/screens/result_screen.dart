import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List generatedImage;
  final String productName;
  final Uint8List userPhoto;

  const ResultScreen({
    super.key,
    required this.generatedImage,
    required this.productName,
    required this.userPhoto,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showComparison = false;
  bool _isSaving = false;
  bool _isSharing = false;

  /// Save the generated image to the device photo gallery.
  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      // Check / request gallery access
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }
      await Gal.putImageBytes(
        widget.generatedImage,
        album: 'Jewellery TryOn',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Saved to your photo gallery!'),
        backgroundColor: Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
      ));
    } on GalException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('⚠️ ${e.type.message}'),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Save failed: $e'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Share the generated image via the system share sheet.
  Future<void> _shareImage() async {
    setState(() => _isSharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/jewellery_tryon_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(widget.generatedImage);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/jpeg')],
        text: '✨ Look at me wearing ${widget.productName}! '
            'Try on jewellery with the Jewellery TryOn app — Powered by Gemini AI.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Share failed: $e'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Your Look ✨',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () =>
                setState(() => _showComparison = !_showComparison),
            icon: Icon(
              _showComparison ? Icons.auto_awesome : Icons.compare,
              color: AppConstants.goldColor,
              size: 18,
            ),
            label: Text(
              _showComparison ? 'Result' : 'Compare',
              style: const TextStyle(color: AppConstants.goldColor),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // ── Main image / comparison view ──────────────────────────────────
        Expanded(
          child: _showComparison
              ? _ComparisonView(
                  before: widget.userPhoto,
                  after: widget.generatedImage)
              : InteractiveViewer(
                  child: Center(
                      child: Image.memory(widget.generatedImage,
                          fit: BoxFit.contain))),
        ),

        // ── Bottom action panel ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2)),
            ),

            // Caption
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.auto_awesome,
                  color: AppConstants.goldColor, size: 17),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'You wearing ${widget.productName}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Text(
              'Generated by Gemini AI  •  Pinch to zoom',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),

            const SizedBox(height: 18),

            // ── Save & Share row ──────────────────────────────────────────
            Row(children: [
              Expanded(
                child: _ActionButton(
                  icon: _isSaving
                      ? null
                      : Icons.save_alt_rounded,
                  label: _isSaving ? 'Saving…' : 'Save',
                  color: AppConstants.goldColor,
                  foreground: Colors.black87,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _saveToGallery,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: _isSharing ? null : Icons.share_rounded,
                  label: _isSharing ? 'Sharing…' : 'Share',
                  color: Colors.white.withOpacity(0.12),
                  foreground: Colors.white,
                  isLoading: _isSharing,
                  onPressed: _isSharing ? null : _shareImage,
                  outlined: true,
                ),
              ),
            ]),

            const SizedBox(height: 10),

            // ── Navigation row ────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ── Comparison view ────────────────────────────────────────────────────────

class _ComparisonView extends StatelessWidget {
  final Uint8List before, after;
  const _ComparisonView({required this.before, required this.after});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Stack(fit: StackFit.expand, children: [
        Image.memory(before, fit: BoxFit.cover),
        const Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(child: _Label('Before')),
        ),
      ])),
      Container(width: 2, color: AppConstants.goldColor),
      Expanded(child: Stack(fit: StackFit.expand, children: [
        Image.memory(after, fit: BoxFit.cover),
        const Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(child: _Label('After ✨')),
        ),
      ])),
    ]);
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );
}

// ── Generic action button ──────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final Color foreground;
  final bool isLoading;
  final bool outlined;
  final VoidCallback? onPressed;

  const _ActionButton({
    this.icon,
    required this.label,
    required this.color,
    required this.foreground,
    this.isLoading = false,
    this.outlined = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: foreground),
          )
        else if (icon != null)
          Icon(icon, size: 17, color: foreground),
        const SizedBox(width: 7),
        Text(label,
            style: TextStyle(
                color: foreground, fontWeight: FontWeight.bold)),
      ],
    );

    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final padding = const EdgeInsets.symmetric(vertical: 13);

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: foreground.withOpacity(0.4)),
          padding: padding,
          shape: shape,
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foreground,
        padding: padding,
        shape: shape,
        elevation: 3,
      ),
      child: child,
    );
  }
}
