import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A full-screen live-camera preview that lets the user take a selfie.
/// Returns [Uint8List] of the captured photo via [Navigator.pop].
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCamera = 1; // front camera by default
  bool _isCapturing = false;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on this device.';
          _isInitializing = false;
        });
        return;
      }
      // prefer front camera (index 1 for most devices)
      final idx = _cameras.length > 1 ? 1 : 0;
      await _initController(idx);
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access camera: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _initController(int cameraIndex) async {
    await _controller?.dispose();
    final cam = _cameras[cameraIndex];
    final ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await ctrl.initialize();
      if (!mounted) return;
      setState(() {
        _controller = ctrl;
        _selectedCamera = cameraIndex;
        _isInitializing = false;
        _errorMessage = null;
      });
    } on CameraException catch (e) {
      setState(() {
        _errorMessage = e.description ?? 'Camera error';
        _isInitializing = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitializing = true);
    final next = (_selectedCamera + 1) % _cameras.length;
    await _initController(next);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    final next = _flashOn ? FlashMode.off : FlashMode.torch;
    await _controller!.setFlashMode(next);
    setState(() => _flashOn = !_flashOn);
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      if (mounted) Navigator.pop(context, bytes);
    } catch (e) {
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Capture failed: $e')));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initController(_selectedCamera);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(fit: StackFit.expand, children: [
          // ── Camera preview ──────────────────────────────────────────────
          if (_isInitializing)
            const Center(
                child: CircularProgressIndicator(color: AppConstants.goldColor))
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.camera_alt_outlined,
                      color: Colors.white38, size: 64),
                  const SizedBox(height: 16),
                  Text(_errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back',
                        style: TextStyle(color: AppConstants.goldColor)),
                  ),
                ]),
              ),
            )
          else
            ClipRect(
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),

          // ── Oval face guide ─────────────────────────────────────────────
          if (!_isInitializing && _errorMessage == null)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.58,
                height: MediaQuery.of(context).size.height * 0.40,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(
                      color: AppConstants.goldColor.withOpacity(0.65),
                      width: 2),
                ),
              ),
            ),

          // ── Top bar ─────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                  ),
                  const Text('Take a Selfie',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed:
                        (!_isInitializing && _errorMessage == null)
                            ? _toggleFlash
                            : null,
                    icon: Icon(
                      _flashOn ? Icons.flash_on : Icons.flash_off,
                      color: _flashOn ? AppConstants.goldColor : Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Hint text ───────────────────────────────────────────────────
          if (!_isInitializing && _errorMessage == null)
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: Text(
                'Align your face within the oval',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
            ),

          // ── Bottom controls ─────────────────────────────────────────────
          if (!_isInitializing && _errorMessage == null)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Switch camera
                  _ControlButton(
                    icon: Icons.flip_camera_ios_rounded,
                    onTap: _cameras.length > 1 ? _switchCamera : null,
                    size: 46,
                  ),
                  // Capture button
                  GestureDetector(
                    onTap: _isCapturing ? null : _capture,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 3.5),
                        color: _isCapturing
                            ? Colors.white38
                            : Colors.white.withOpacity(0.15),
                      ),
                      child: _isCapturing
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Icon(Icons.camera_alt,
                              color: Colors.white, size: 34),
                    ),
                  ),
                  // Placeholder for symmetry
                  const SizedBox(width: 46),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  const _ControlButton(
      {required this.icon, required this.onTap, this.size = 44});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.52),
        ),
      );
}
