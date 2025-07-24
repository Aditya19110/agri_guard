import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Service class for managing analysis history data
/// 
/// Provides methods to save, retrieve, and manage crop analysis history
/// using Firebase Firestore.
class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Saves an analysis result to the user's history
  /// 
  /// Returns true if successful, false otherwise
  Future<bool> saveAnalysisResult({
    required String diseaseResult,
    required double confidence,
    required String imagePath,
    String? recommendations,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_history')
          .add({
        'diseaseResult': diseaseResult,
        'confidence': confidence,
        'imagePath': imagePath,
        'recommendations': recommendations ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'additionalData': additionalData ?? {},
      });

      // Update user's analysis count
      await _updateAnalysisCount(user.uid);

      return true;
    } catch (e) {
      print('Error saving analysis result: $e');
      return false;
    }
  }

  /// Gets analysis history for the current user
  /// 
  /// Returns a stream of analysis history documents
  Stream<QuerySnapshot> getAnalysisHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('analysis_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Gets analysis history as a one-time fetch
  /// 
  /// Returns a list of analysis history documents
  Future<List<QueryDocumentSnapshot>> getAnalysisHistoryOnce() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_history')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching analysis history: $e');
      return [];
    }
  }

  /// Deletes a specific analysis from history
  /// 
  /// Returns true if successful, false otherwise
  Future<bool> deleteAnalysis(String analysisId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_history')
          .doc(analysisId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting analysis: $e');
      return false;
    }
  }

  /// Gets the total number of analyses performed by the user
  Future<int> getAnalysisCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_history')
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting analysis count: $e');
      return 0;
    }
  }

  /// Updates the user's total analysis count in their profile
  Future<void> _updateAnalysisCount(String userId) async {
    try {
      final count = await getAnalysisCount();
      await _firestore.collection('users').doc(userId).update({
        'analysisCount': count,
        'lastAnalysisAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating analysis count: $e');
    }
  }

  /// Gets analysis statistics for the user
  Future<Map<String, dynamic>> getAnalysisStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analysis_history')
          .get();

      int totalAnalyses = querySnapshot.docs.length;
      int healthyCount = 0;
      int diseaseCount = 0;
      double averageConfidence = 0;
      double totalConfidence = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final diseaseResult = data['diseaseResult'] ?? '';
        final confidence = (data['confidence'] ?? 0.0).toDouble();

        totalConfidence += confidence;

        if (diseaseResult.toLowerCase().contains('healthy')) {
          healthyCount++;
        } else {
          diseaseCount++;
        }
      }

      if (totalAnalyses > 0) {
        averageConfidence = totalConfidence / totalAnalyses;
      }

      return {
        'totalAnalyses': totalAnalyses,
        'healthyCount': healthyCount,
        'diseaseCount': diseaseCount,
        'averageConfidence': averageConfidence,
      };
    } catch (e) {
      print('Error getting analysis stats: $e');
      return {};
    }
  }
}

/// Model class for analysis history items
class AnalysisHistoryItem {
  final String id;
  final String diseaseResult;
  final double confidence;
  final String imagePath;
  final String recommendations;
  final DateTime timestamp;
  final Map<String, dynamic> additionalData;

  AnalysisHistoryItem({
    required this.id,
    required this.diseaseResult,
    required this.confidence,
    required this.imagePath,
    required this.recommendations,
    required this.timestamp,
    this.additionalData = const {},
  });

  factory AnalysisHistoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AnalysisHistoryItem(
      id: doc.id,
      diseaseResult: data['diseaseResult'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      imagePath: data['imagePath'] ?? '',
      recommendations: data['recommendations'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'] ?? {},
    );
  }

  /// Gets a color based on the disease result
  Color getResultColor() {
    if (diseaseResult.toLowerCase().contains('healthy')) {
      return const Color(0xFF4CAF50); // Green for healthy
    } else if (confidence < 0.5) {
      return const Color(0xFFFF9800); // Orange for uncertain
    } else {
      return const Color(0xFFF44336); // Red for disease
    }
  }

  /// Gets an icon based on the disease result
  IconData getResultIcon() {
    if (diseaseResult.toLowerCase().contains('healthy')) {
      return Icons.check_circle;
    } else if (confidence < 0.5) {
      return Icons.help;
    } else {
      return Icons.warning;
    }
  }
}
