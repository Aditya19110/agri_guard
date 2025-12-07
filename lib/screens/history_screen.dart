import 'package:flutter/material.dart';
import 'package:agri_gurad/config/app_theme.dart';
import 'package:agri_gurad/services/history_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  String _sortBy = 'date'; // 'date', 'disease', 'confidence'
  bool _ascending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Analysis History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = false;
                }
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'date',
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color:
                              _sortBy == 'date'
                                  ? AppTheme.primaryGreen
                                  : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('Sort by Date', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'disease',
                    child: Row(
                      children: [
                        Icon(
                          Icons.bug_report_rounded,
                          color:
                              _sortBy == 'disease'
                                  ? AppTheme.primaryGreen
                                  : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('Sort by Disease', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'confidence',
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color:
                              _sortBy == 'confidence'
                                  ? AppTheme.primaryGreen
                                  : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('Sort by Confidence', style: GoogleFonts.inter()),
                      ],
                    ),
                  ),
                ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryGreen, AppTheme.backgroundColor],
            stops: [0.0, 0.2],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _historyService.getAnalysisHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading history',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final historyDocs = snapshot.data?.docs ?? [];

                  if (historyDocs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final historyItems =
                      historyDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return AnalysisHistoryItem(
                          id: doc.id,
                          diseaseResult: data['diseaseResult'] ?? '',
                          confidence: (data['confidence'] ?? 0.0).toDouble(),
                          timestamp:
                              (data['timestamp'] as Timestamp?)?.toDate() ??
                              DateTime.now(),
                          recommendations: data['recommendations'] ?? '',
                          imagePath: data['imagePath'] ?? '',
                          additionalData: Map<String, dynamic>.from(
                            data['additionalData'] ?? {},
                          ),
                        );
                      }).toList();

                  switch (_sortBy) {
                    case 'date':
                      historyItems.sort(
                        (a, b) =>
                            _ascending
                                ? a.timestamp.compareTo(b.timestamp)
                                : b.timestamp.compareTo(a.timestamp),
                      );
                      break;
                    case 'disease':
                      historyItems.sort(
                        (a, b) =>
                            _ascending
                                ? a.diseaseResult.compareTo(b.diseaseResult)
                                : b.diseaseResult.compareTo(a.diseaseResult),
                      );
                      break;
                    case 'confidence':
                      historyItems.sort(
                        (a, b) =>
                            _ascending
                                ? a.confidence.compareTo(b.confidence)
                                : b.confidence.compareTo(a.confidence),
                      );
                      break;
                  }

                  return Column(
                    children: [
                      _buildStatsHeader(historyItems),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: historyItems.length,
                          itemBuilder: (itemContext, index) {
                            final item = historyItems[index];
                            return Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: itemContext,
                                  builder:
                                      (BuildContext dialogContext) => AlertDialog(
                                        title: const Text("Delete Analysis?"),
                                        content: const Text(
                                          "Are you sure you want to delete this record? This action cannot be undone.",
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(dialogContext).pop(
                                                  false,
                                                ),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(dialogContext).pop(
                                                  true,
                                                ),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              onDismissed: (direction) async {
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                await _historyService.deleteAnalysis(item.id);
                                if (!mounted) return;
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Record deleted'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              child: _buildHistoryCard(item).animate().fadeIn(duration: 400.ms).slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOutQuad,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      margin: const EdgeInsets.only(top: 40),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_list_bulleted_rounded,
              size: 60,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No History Yet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start analyzing crops to build your history',
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(List<AnalysisHistoryItem> items) {
    final total = items.length;
    final avg =
        items.isEmpty
            ? 0.0
            : items.map((e) => e.confidence).reduce((a, b) => a + b) / total;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Scans',
              total.toString(),
              Icons.qr_code_scanner,
            ),
            Container(height: 40, width: 1, color: Colors.grey[200]),
            _buildStatItem(
              'Avg. Confidence',
              '${(avg * 100).toInt()}%',
              Icons.analytics_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(AnalysisHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetailDialog(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getDiseaseColor(
                      item.diseaseResult,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.spa_rounded,
                    color: _getDiseaseColor(item.diseaseResult),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.diseaseResult,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd • h:mm a').format(item.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildConfidenceBadge(item.confidence),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).round();
    Color color =
        percentage >= 80 ? AppTheme.primaryGreen : AppTheme.primaryOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percentage%',
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getDiseaseColor(String disease) {
    if (disease.toLowerCase().contains('healthy')) return AppTheme.primaryGreen;
    return AppTheme.primaryOrange;
  }

  void _showDetailDialog(AnalysisHistoryItem item) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Analysis Details',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (item.imagePath.isNotEmpty)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            item.imagePath.startsWith('http')
                                ? Image.network(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image_rounded,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                )
                                : Image.file(
                                  File(item.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image_rounded,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Disease Detected', item.diseaseResult),
                  _buildDetailRow(
                    'Confidence Score',
                    '${(item.confidence * 100).toStringAsFixed(1)}%',
                  ),
                  _buildDetailRow(
                    'Date',
                    DateFormat('MMMM dd, yyyy').format(item.timestamp),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Recommendations',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.recommendations.isNotEmpty
                          ? item.recommendations
                          : 'No recommendations available.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        final success = await _historyService.deleteAnalysis(
                          item.id,
                        );
                        if (!mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Record deleted'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Delete Record',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
