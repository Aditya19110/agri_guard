import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:agri_gurad/config/app_theme.dart';

class PredictionPage extends StatefulWidget {
  final File? imageFile;

  const PredictionPage({super.key, this.imageFile});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> with TickerProviderStateMixin {
  String _predictionResult = '';
  double _confidence = 0.0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Disease labels (update these based on your trained model)
  final List<String> _diseaseLabels = [
    'Healthy',
    'Bacterial Blight',
    'Brown Spot',
    'Leaf Smut',
    'Blast Disease',
    'Tungro',
    // Add more disease labels as per your model
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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
      _predictionResult = '';
      _confidence = 0.0;
    });

    try {
      // Load the TensorFlow Lite model
      final interpreter = await Interpreter.fromAsset('assets/tfmodel/agriguard_model.tflite');
      
      // Preprocess the image
      final inputImage = await _preprocessImage(widget.imageFile!);
      
      // Run inference
      final output = List.filled(1 * _diseaseLabels.length, 0.0).reshape([1, _diseaseLabels.length]);
      interpreter.run(inputImage, output);
      
      // Process the output
      final predictions = output[0] as List<double>;
      final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      
      setState(() {
        _predictionResult = _diseaseLabels[maxIndex];
        _confidence = predictions[maxIndex];
        _isLoading = false;
      });
      
      interpreter.close();
    } catch (e) {
      setState(() {
        _predictionResult = 'Error occurred during prediction';
        _confidence = 0.0;
        _isLoading = false;
      });
      
      // Show error to user
      if (mounted) {
        _showErrorSnackBar('Failed to analyze image. Please try again.');
      }
    }
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Unable to decode image');
    }
    
    // Resize image to model input size (typically 224x224 for most models)
    final resizedImage = img.copyResize(image, width: 224, height: 224);
    
    // Normalize pixel values to [0, 1]
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Disease Analysis'),
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
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  child: widget.imageFile != null
                      ? Image.file(
                          widget.imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: AppTheme.lightGreen,
                          child: const Center(
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              // Analysis Results Card
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: AppTheme.primaryGreen,
                          size: AppConstants.iconMedium,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Analysis Results',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.paddingLarge),
                    
                    if (_isLoading) ...[
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryGreen,
                            ),
                            SizedBox(height: AppConstants.paddingMedium),
                            Text(
                              'Analyzing image...',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_predictionResult.isNotEmpty) ...[
                      // Disease Result
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: _getResultColor(_predictionResult).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          border: Border.all(
                            color: _getResultColor(_predictionResult).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _predictionResult.toLowerCase() == 'healthy'
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: _getResultColor(_predictionResult),
                              size: AppConstants.iconLarge,
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detected: $_predictionResult',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: _getResultColor(_predictionResult),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Confidence Bar
                      Text(
                        'Confidence Level',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      LinearProgressIndicator(
                        value: _confidence,
                        backgroundColor: AppTheme.lightGreen,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getResultColor(_predictionResult),
                        ),
                        minHeight: 8,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Recommendations
                      Text(
                        'Recommendations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                        ),
                        child: Text(
                          _getRecommendation(_predictionResult),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          'Ready to analyze image',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _predictDisease,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Re-analyze',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
                      label: const Text(
                        'Back',
                        style: TextStyle(color: AppTheme.primaryGreen),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
