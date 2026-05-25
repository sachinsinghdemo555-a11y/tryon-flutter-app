import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import 'product_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.55,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppConstants.deepPurple, Color(0xFF7B2FBE)],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstants.goldColor.withOpacity(0.15),
                              border: Border.all(color: AppConstants.goldColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: AppConstants.goldColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 4)
                              ],
                            ),
                            child: const Center(child: Text('💎', style: TextStyle(fontSize: 54))),
                          ),
                          const SizedBox(height: 28),
                          Text('Jewellery TryOn',
                              style: GoogleFonts.playfairDisplay(
                                  color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppConstants.goldColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppConstants.goldColor.withOpacity(0.6)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, color: AppConstants.goldColor, size: 15),
                                SizedBox(width: 6),
                                Text('Powered by Gemini AI',
                                    style: TextStyle(
                                        color: AppConstants.goldColor, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
                      child: Column(
                        children: [
                          Text('Experience jewellery\nlike never before',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.deepPurple,
                                  height: 1.3)),
                          const SizedBox(height: 10),
                          Text(
                              'Select a piece, snap a selfie, and see yourself\nadorned with stunning jewellery — instantly.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13.5, color: Colors.grey[600], height: 1.55)),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => const ProductSelectionScreen())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 6,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Start TryOn',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StepChip(emoji: '💎', label: 'Select\nJewellery', step: '1'),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                              _StepChip(emoji: '📸', label: 'Your\nPhoto', step: '2'),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                              _StepChip(emoji: '✨', label: 'See\nResult', step: '3'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final String emoji, label, step;
  const _StepChip({required this.emoji, required this.label, required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: AppConstants.deepPurple.withOpacity(0.08), shape: BoxShape.circle),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: AppConstants.goldColor, shape: BoxShape.circle),
            child: Center(
                child:
                    Text(step, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
    ]);
  }
}
