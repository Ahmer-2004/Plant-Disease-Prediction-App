class ModelConfig {
  // Model input dimensions (matches your training notebook exactly)
  static const int inputWidth = 224;   // IMG_WIDTH from training
  static const int inputHeight = 224;   // IMG_HEIGHT from training  
  static const int inputChannels = 3;   // RGB channels
  
  // Model output (20 classes from the new model)
  static const int numClasses = 20;
  
  // Confidence thresholds - Optimized for plant disease model
  static const double highConfidenceThreshold = 0.85;
  static const double mediumConfidenceThreshold = 0.70;
  static const double lowConfidenceThreshold = 0.50;
  
  // Model file path
  static const String modelPath = 'assets/models/model.tflite';
  
  // Class labels for plant diseases (20 classes from the new TFLite model)
  static const List<String> classLabels = [
    'Maize___Common Rust',
    'Potato___Potato Healthy',
    'Rice___Rice Leaf Blast',
    'Rice___Rice Neck Blast',
    'Tomato___Tomato___Bacterial_spot',
    'Tomato___Tomato___Early_blight',
    'Tomato___Tomato___Late_blight',
    'Tomato___Tomato___Leaf_Mold',
    'Tomato___Tomato___Septoria_leaf_spot',
    'Tomato___Tomato___Spider_mites Two-spotted_spider_mite',
    'Tomato___Tomato___Target_Spot',
    'Tomato___Tomato___Tomato_Yellow_Leaf_Curl_Virus',
    'Tomato___Tomato___Tomato_mosaic_virus',
    'Tomato___Tomato___healthy',
    'sugarcane___Bacterial Blight',
    'sugarcane___Healthy',
    'sugarcane___Red Rot',
    'wheat leaf___Healthy',
    'wheat leaf___Septoria',
    'wheat leaf___Stripe Rust'
  ];
  
  // Disease categories for better organization
  static const Map<String, List<String>> diseaseCategories = {
    'Maize': ['Maize___Common Rust'],
    'Potato': ['Potato___Potato Healthy'],
    'Rice': ['Rice___Rice Leaf Blast', 'Rice___Rice Neck Blast'],
    'Tomato': [
      'Tomato___Tomato___Bacterial_spot',
      'Tomato___Tomato___Early_blight',
      'Tomato___Tomato___Late_blight',
      'Tomato___Tomato___Leaf_Mold',
      'Tomato___Tomato___Septoria_leaf_spot',
      'Tomato___Tomato___Spider_mites Two-spotted_spider_mite',
      'Tomato___Tomato___Target_Spot',
      'Tomato___Tomato___Tomato_Yellow_Leaf_Curl_Virus',
      'Tomato___Tomato___Tomato_mosaic_virus',
      'Tomato___Tomato___healthy',
    ],
    'Sugarcane': [
      'sugarcane___Bacterial Blight',
      'sugarcane___Healthy',
      'sugarcane___Red Rot'
    ],
    'Wheat': [
      'wheat leaf___Healthy',
      'wheat leaf___Septoria',
      'wheat leaf___Stripe Rust'
    ]
  };
  
  // Get formatted disease name
  static String getFormattedDiseaseName(String disease) {
    return disease
        .replaceAll('___', ' - ')
        .replaceAll('_', ' ')
        .replaceAll('Tomato Tomato', 'Tomato')
        .replaceAll('wheat leaf', 'Wheat')
        .replaceAll('sugarcane', 'Sugarcane')
        .trim();
  }
  
  // Get plant type from disease name
  static String getPlantType(String disease) {
    final d = disease.toLowerCase();
    if (d.contains('maize') || d.contains('corn')) return 'Maize';
    if (d.contains('potato')) return 'Potato';
    if (d.contains('rice')) return 'Rice';
    if (d.contains('tomato')) return 'Tomato';
    if (d.contains('sugarcane')) return 'Sugarcane';
    if (d.contains('wheat')) return 'Wheat';
    return 'Unknown';
  }
  
  // Check if disease is healthy
  static bool isHealthy(String disease) {
    return disease.toLowerCase().contains('healthy');
  }
  
  // Get confidence level description
  static String getConfidenceDescription(double confidence) {
    if (confidence >= highConfidenceThreshold) {
      return 'High Confidence';
    } else if (confidence >= mediumConfidenceThreshold) {
      return 'Medium Confidence';
    } else if (confidence >= lowConfidenceThreshold) {
      return 'Low Confidence';
    } else {
      return 'Very Low Confidence';
    }
  }
  
  // Get confidence color
  static int getConfidenceColor(double confidence) {
    if (confidence >= highConfidenceThreshold) {
      return 0xFF4CAF50; // Green
    } else if (confidence >= mediumConfidenceThreshold) {
      return 0xFFFF9800; // Orange
    } else if (confidence >= lowConfidenceThreshold) {
      return 0xFFFF5722; // Deep Orange
    } else {
      return 0xFFF44336; // Red
    }
  }
}
