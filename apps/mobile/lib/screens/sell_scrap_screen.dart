import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'dart:math';

class SellScrapScreen extends StatefulWidget {
  const SellScrapScreen({super.key});

  @override
  State<SellScrapScreen> createState() => _SellScrapScreenState();
}

class _SellScrapScreenState extends State<SellScrapScreen> {
  String? _imagePath;
  bool _loading = false;
  Map<String, dynamic>? _result;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _result = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get image')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_imagePath == null) return;
    setState(() => _loading = true);

    try {
      final lotId = 'demo-lot-${Random().nextInt(1000)}';
      final classification = await ApiService.classify(lotId, _imagePath!);
      setState(() {
        _result = classification;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to analyze image. Ensure backend is running.')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        '←',
                        style: TextStyle(
                          fontSize: 24,
                          color: const Color(0xFF1B3B86),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Sell Scrap',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B3B86),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _imagePath == null
                    ? _buildPlaceholder()
                    : _buildResultView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identify material',
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            color: const Color(0xFF1B3B86),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Snap a photo to classify and estimate value.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        _buildActionButton(
            'Take Photo', () => _pickImage(ImageSource.camera), true),
        const SizedBox(height: 15),
        _buildActionButton('Choose from Gallery',
            () => _pickImage(ImageSource.gallery), false),
      ],
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 350,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
              image: DecorationImage(
                image: FileImage(File(_imagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_result == null)
            _buildActionButton('Analyze Scrap', _analyzeImage, true,
                isLoading: _loading)
          else
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Complete',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B3B86),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildResultRow(
                      'Category', _result!['category'] ?? 'Unknown'),
                  _buildResultRow('Confidence',
                      '${((_result!['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
                  _buildResultRow(
                      'Est. Price', '₹${_result!['price'] ?? 0}/kg'),
                  const SizedBox(height: 30),
                  _buildActionButton('Proceed to Weight', () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: const Text('MVP'),
                              content: const Text(
                                  'Moving to weight entry is next in the flow!'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'))
                              ],
                            ));
                  }, true),
                ],
              ),
            ),
          if (!_loading && _result == null)
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: GestureDetector(
                onTap: () => setState(() => _imagePath = null),
                child: Text(
                  'Retake Photo',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1B3B86),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B3B86))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, bool isPrimary,
      {bool isLoading = false}) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF1B3B86) : Colors.transparent,
          border: isPrimary ? null : Border.all(color: const Color(0xFF1B3B86)),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    color: Color(0xFFF3F0E6), strokeWidth: 2))
            : Text(
                text.toUpperCase(),
                style: GoogleFonts.inter(
                  color: isPrimary
                      ? const Color(0xFFF3F0E6)
                      : const Color(0xFF1B3B86),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
