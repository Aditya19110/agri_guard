import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agri_gurad/config/app_theme.dart';
import 'package:agri_gurad/services/history_service.dart';

class PredictionPage extends StatefulWidget {
  final File? imageFile;

  const PredictionPage({super.key, this.imageFile});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage>
    with TickerProviderStateMixin {
  String _predictionResult = '';
  double _confidence = 0.0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final HistoryService _historyService = HistoryService();

  // Disease labels (update these based on your trained model)
  final List<String> _diseaseLabels = [
    'Healthy',
    'Bacterial Blight',
    'Brown Spot',
    'Leaf Smut',
    'Blast Disease',
    'Tungro',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    if (widget.imageFile != null) {
      _predictDisease();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _predictDisease() async {
    if (widget.imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final interpreter = await Interpreter.fromAsset(
        'assets/tfmodel/agriguard_model.tflite',
      );
      final inputImage = await _preprocessImage(widget.imageFile!);
      final output = List.filled(
        1 * _diseaseLabels.length,
        0.0,
      ).reshape([1, _diseaseLabels.length]);
      interpreter.run(inputImage, output);

      final predictions = output[0] as List<double>;
      final maxIndex = predictions.indexOf(
        predictions.reduce((a, b) => a > b ? a : b),
      );

      setState(() {
        _predictionResult = _diseaseLabels[maxIndex];
        _confidence = predictions[maxIndex];
        _isLoading = false;
      });

      await _saveAnalysisToHistory();

      interpreter.close();
    } catch (e) {
      setState(() {
        _predictionResult = 'Error occurred during prediction';
        _confidence = 0.0;
        _isLoading = false;
      });

      if (mounted) {
        _showErrorSnackBar('Failed to analyze image. Please try again.');
        // debugPrint('Error analyzing image: $e');
      }
    }
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
    File imageFile,
  ) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Unable to decode image');

    final resizedImage = img.copyResize(image, width: 224, height: 224);

    final input = List.generate(
      1,
      (index) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) => List.generate(3, (c) {
            final pixel = resizedImage.getPixel(x, y);
            if (c == 0) return pixel.r / 255.0; // Red
            if (c == 1) return pixel.g / 255.0; // Green
            return pixel.b / 255.0; // Blue
          }),
        ),
      ),
    );

    return input;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getRecommendation(String disease) {
    switch (disease.toLowerCase()) {
      case 'healthy':
        return 'Your crop looks healthy! Continue with regular care and monitoring.';
      case 'bacterial blight':
        return 'Apply copper-based fungicides and improve field drainage. Remove infected plant parts.';
      case 'brown spot':
        return 'Use resistant varieties and apply fungicides. Improve soil fertility with potassium.';
      case 'leaf smut':
        return 'Remove infected leaves and apply appropriate fungicides. Ensure proper spacing for air circulation.';
      case 'blast disease':
        return 'Apply tricyclazole or carbendazim. Avoid excessive nitrogen fertilization.';
      case 'tungro':
        return 'Control green leafhopper vectors and use resistant varieties. Remove infected plants immediately.';
      default:
        return 'Consult with local agricultural experts for specific treatment recommendations.';
    }
  }

  Color _getResultColor(String disease) {
    if (disease.toLowerCase() == 'healthy') {
      return AppTheme.successColor;
    } else if (_confidence > 0.8) {
      return AppTheme.errorColor;
    } else {
      return AppTheme.primaryOrange;
    }
  }

  Future<void> _saveAnalysisToHistory() async {
    if (widget.imageFile == null || _predictionResult.isEmpty) return;

    try {
      await _historyService.saveAnalysisResult(
        diseaseResult: _predictionResult,
        confidence: _confidence,
        imagePath: widget.imageFile!.path,
        recommendations: _getRecommendation(_predictionResult),
        additionalData: {
          'imageSize': await widget.imageFile!.length(),
          'analysisDate': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis saved to history'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // print('Error saving analysis to history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Disease Analysis', style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Display
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child:
                      widget.imageFile != null
                          ? Image.file(
                            widget.imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                          : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Results Section
              if (_isLoading)
                _buildLoadingState()
              else if (_predictionResult.isNotEmpty)
                _buildResults()
              else
                const Center(child: Text("Ready to analyze")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(color: AppTheme.primaryGreen),
        const SizedBox(height: 16),
        Text(
          'Analyzing Crop Health...',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final color = _getResultColor(_predictionResult);

    return Column(
      children: [
        // Result Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.surfaceColor.withValues(alpha: 0.9),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detection Result',
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _predictionResult,
                        style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 8.0,
                    percent: _confidence,
                    center: Text(
                      "${(_confidence * 100).toInt()}%",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    progressColor: color,
                    backgroundColor: color.withValues(alpha: 0.1),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1000,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.primaryOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Recommendation',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getRecommendation(_predictionResult),
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _predictDisease,
                icon: const Icon(Icons.refresh),
                label: const Text('Re-Analyze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report saved to Downloads (Mock)'),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Save Report'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
