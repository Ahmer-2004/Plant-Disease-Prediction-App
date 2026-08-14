import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../config/model_config.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class PlantDiseaseProvider with ChangeNotifier {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  bool _isLoading = false;
  String? _predictionResult;
  double? _confidence;
  String? _error;

  bool get isModelLoaded => _isModelLoaded;
  bool get isLoading => _isLoading;
  String? get predictionResult => _predictionResult;
  double? get confidence => _confidence;
  String? get error => _error;

  PlantDiseaseProvider();

  /// Loads the float16 TFLite model from assets.
  Future<void> loadModel() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _interpreter?.close();
      _interpreter = null;

      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        ModelConfig.modelPath,
        options: options,
      );

      // Resize to explicit [1, 224, 224, 3] to fix dynamic-batch issues
      _interpreter!.resizeInputTensor(
        0,
        [1, ModelConfig.inputHeight, ModelConfig.inputWidth, 3],
      );
      _interpreter!.allocateTensors();

      debugPrint(
        '✅ Model ready | input=${_interpreter!.getInputTensor(0).shape} | output=${_interpreter!.getOutputTensor(0).shape}',
      );

      _isModelLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (e, st) {
      debugPrint('❌ loadModel error: $e\n$st');
      _error = 'Failed to load AI model. Restart the app.';
      _isModelLoaded = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ───────────────────────────────────────────────────────────
  //  Core TFLite inference
  // ───────────────────────────────────────────────────────────
  Future<void> _runInference(Uint8List imageBytes) async {
    if (_interpreter == null) throw Exception('Interpreter not initialised');

    // 1. Decode
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) throw Exception('Failed to decode image');

    // 2. Resize to 224×224
    final resized = img.copyResize(
      decoded,
      width: ModelConfig.inputWidth,
      height: ModelConfig.inputHeight,
    );

    // 3. Build a flat Float32List in row-major [H, W, C] order
    //    then wrap in a [1, H, W, C] typed-data buffer for the interpreter.
    final int h = ModelConfig.inputHeight;
    final int w = ModelConfig.inputWidth;
    final int c = 3;
    final pixelBuffer = Float32List(h * w * c);

    int idx = 0;
    // Standard ImageNet normalization (often required by ResNet / MobileNet architectures trained via PyTorch or modern TF pipelines)
    // mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225]
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = resized.getPixel(x, y);

        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;

        pixelBuffer[idx++] = (r - 0.485) / 0.229;
        pixelBuffer[idx++] = (g - 0.456) / 0.224;
        pixelBuffer[idx++] = (b - 0.406) / 0.225;
      }
    }

    // 4. Input tensor: [1, H, W, C] — wrap in a single-element list
    //    tflite_flutter accepts List<Object> where the element is the raw
    //    typed-data buffer with the correct flat byte count.
    final inputAsList = [pixelBuffer.reshape([1, h, w, c])];

    // 5. Output tensor: [1, numClasses] — plain nested list (guaranteed write-through)
    final outputAsList = <int, Object>{
      0: List.generate(1, (_) => List.filled(ModelConfig.numClasses, 0.0)),
    };

    // 6. Run
    _interpreter!.runForMultipleInputs(inputAsList, outputAsList);

    // 7. Extract logits from the output map
    final rawOutput = outputAsList[0]! as List<dynamic>;
    final logits = (rawOutput[0] as List<dynamic>).cast<double>();

    debugPrint('Logits range: ${logits.reduce(math.min).toStringAsFixed(2)} to ${logits.reduce(math.max).toStringAsFixed(2)}');

    // 8. Softmax → probabilities
    final probs = _softmax(logits);

    // 9. Simple Argmax (Highest individual class probability)
    int finalMaxIdx = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[finalMaxIdx]) finalMaxIdx = i;
    }

    _confidence = probs[finalMaxIdx];

    // 10. Debug top-3 raw probabilities
    debugPrint('--- Simple Inference Results ---');
    final sorted = List<int>.generate(probs.length, (i) => i)
      ..sort((a, b) => probs[b].compareTo(probs[a]));
    for (int i = 0; i < math.min(3, sorted.length); i++) {
      debugPrint('  Rank #${i + 1}: ${ModelConfig.classLabels[sorted[i]]} — ${(probs[sorted[i]] * 100).toStringAsFixed(1)}%');
    }

    // 11. Always return the model's top prediction.
    _predictionResult = ModelConfig.getFormattedDiseaseName(
      ModelConfig.classLabels[finalMaxIdx],
    );
  }

  // ───────────────────────────────────────────────────────────
  //  Public predict API
  // ───────────────────────────────────────────────────────────
  Future<void> predictFromImage(File imageFile) async {
    if (!_isModelLoaded) {
      _error = 'AI model not ready. Please wait.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isPlant = await _isImagePlant(imageFile.path);
      if (!isPlant) {
        _error = 'Rejected: Not a plant. Please capture a leaf or plant.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final bytes = await imageFile.readAsBytes();
      await _runInference(bytes);
    } catch (e) {
      debugPrint('predictFromImage error: $e');
      _error = 'Analysis failed: ${e.toString().replaceAll('Exception: ', '')}';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> _isImagePlant(String imagePath) async {
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.3),
    );
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await labeler.processImage(inputImage);
      labeler.close();

      // Debug: print all labels so we can see what ML Kit detected
      debugPrint('🔍 ML Kit labels:');
      for (final label in labels) {
        debugPrint('  → ${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)');
      }

      const plantKeywords = [
        'plant', 'flower', 'leaf', 'tree', 'vegetation',
        'herb', 'grass', 'garden', 'shrub', 'weed',
        'food', 'produce', 'vegetable', 'fruit', 'crop',
        'houseplant', 'botany', 'flora', 'green', 'natural',
        'agriculture', 'organic', 'seed', 'petal', 'stem',
        'vine', 'fern', 'moss', 'bloom', 'blossom',
      ];

      return labels.any((label) {
        final text = label.label.toLowerCase();
        return plantKeywords.any((keyword) => text.contains(keyword));
      });
    } catch (e) {
      debugPrint('ML Kit prefilter error: $e');
      labeler.close();
      return true; // Fallback if ML Kit fails
    }
  }

  Future<void> predictFromBytes(Uint8List imageBytes) async {
    if (!_isModelLoaded) {
      _error = 'AI model not ready. Please wait.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _runInference(imageBytes);
    } catch (e) {
      debugPrint('predictFromBytes error: $e');
      _error = 'Analysis failed: ${e.toString().replaceAll('Exception: ', '')}';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> predictFromCameraBytes(Uint8List imageBytes) async {
    if (!_isModelLoaded) {
      _error = 'AI model not ready. Please wait.';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _runInference(imageBytes);
    } catch (e) {
      debugPrint('predictFromCameraBytes error: $e');
      _error = 'Camera analysis failed: ${e.toString().replaceAll('Exception: ', '')}';
    }
    _isLoading = false;
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────
  //  Helpers
  // ───────────────────────────────────────────────────────────
  List<double> _softmax(List<double> logits) {
    final maxVal = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((l) => math.exp(l - maxVal)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  void clearPrediction() {
    _predictionResult = null;
    _confidence = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}
