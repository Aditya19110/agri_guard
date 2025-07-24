import 'package:flutter/material.dart';
import 'package:agri_gurad/widgets/app_drawer.dart';
import 'package:agri_gurad/config/app_theme.dart';
import 'package:agri_gurad/services/history_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: const Text('Analysis History'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
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
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, 
                         color: _sortBy == 'date' ? AppTheme.primaryGreen : null),
                    const SizedBox(width: 8),
                    Text('Sort by Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'disease',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, 
                         color: _sortBy == 'disease' ? AppTheme.primaryGreen : null),
                    const SizedBox(width: 8),
                    Text('Sort by Disease'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'confidence',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, 
                         color: _sortBy == 'confidence' ? AppTheme.primaryGreen : null),
                    const SizedBox(width: 8),
                    Text('Sort by Confidence'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreen,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _historyService.getAnalysisHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading history',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again later',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
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

              // Convert documents to AnalysisHistoryItem objects
              final historyItems = historyDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return AnalysisHistoryItem(
                  id: doc.id,
                  diseaseResult: data['diseaseResult'] ?? '',
                  confidence: (data['confidence'] ?? 0.0).toDouble(),
                  timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  recommendations: data['recommendations'] ?? '',
                  imagePath: data['imagePath'] ?? '',
                  additionalData: Map<String, dynamic>.from(data['additionalData'] ?? {}),
                );
              }).toList();

              // Sort the history items
              switch (_sortBy) {
                case 'date':
                  historyItems.sort((a, b) => _ascending 
                      ? a.timestamp.compareTo(b.timestamp)
                      : b.timestamp.compareTo(a.timestamp));
                  break;
                case 'disease':
                  historyItems.sort((a, b) => _ascending 
                      ? a.diseaseResult.compareTo(b.diseaseResult)
                      : b.diseaseResult.compareTo(a.diseaseResult));
                  break;
                case 'confidence':
                  historyItems.sort((a, b) => _ascending 
                      ? a.confidence.compareTo(b.confidence)
                      : b.confidence.compareTo(a.confidence));
                  break;
              }

              return Column(
                children: [
                  // Header Card with Statistics
                  _buildHeaderWithStats(historyItems),
                  // History list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: historyItems.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(historyItems[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          // Header Card
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: const BoxDecoration(
                    color: AppTheme.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: AppTheme.primaryGreen,
                    size: AppConstants.iconLarge,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Analysis History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track your crop health over time',
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
          
          const SizedBox(height: AppConstants.paddingXLarge),
          
          // Empty State
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingXLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      size: 80,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  Text(
                    'No Analysis History Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingXLarge),
                    child: Text(
                      'Start analyzing your crops to see your history here. Your analysis results will be saved for future reference.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingXLarge),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Start Analysis',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingXLarge,
                        vertical: AppConstants.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithStats(List<AnalysisHistoryItem> items) {
    final totalAnalyses = items.length;
    final avgConfidence = items.isEmpty ? 0.0 : 
        items.map((e) => e.confidence).reduce((a, b) => a + b) / items.length;
    final uniqueDiseases = items.map((e) => e.diseaseResult).toSet().length;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Container(
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: const BoxDecoration(
                    color: AppTheme.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: AppTheme.primaryGreen,
                    size: AppConstants.iconLarge,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Analysis History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track your crop health over time',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.analytics,
                    label: 'Total Analyses',
                    value: totalAnalyses.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.trending_up,
                    label: 'Avg Confidence',
                    value: '${(avgConfidence * 100).toStringAsFixed(1)}%',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.bug_report,
                    label: 'Diseases Found',
                    value: uniqueDiseases.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(AnalysisHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        onTap: () => _showDetailDialog(item),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium, 
                      vertical: AppConstants.paddingSmall
                    ),
                    decoration: BoxDecoration(
                      color: _getDiseaseColor(item.diseaseResult).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      border: Border.all(
                        color: _getDiseaseColor(item.diseaseResult).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.diseaseResult,
                      style: TextStyle(
                        color: _getDiseaseColor(item.diseaseResult),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildConfidenceBadge(item.confidence),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(item.timestamp),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (item.recommendations.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  item.recommendations,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).round();
    Color badgeColor;
    if (percentage >= 80) {
      badgeColor = AppTheme.primaryGreen;
    } else if (percentage >= 60) {
      badgeColor = AppTheme.primaryOrange;
    } else {
      badgeColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall, 
        vertical: 4
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getDiseaseColor(String disease) {
    if (disease.toLowerCase().contains('healthy')) {
      return AppTheme.primaryGreen;
    } else if (disease.toLowerCase().contains('blight') || 
               disease.toLowerCase().contains('rot')) {
      return Colors.red;
    } else {
      return AppTheme.primaryOrange;
    }
  }

  void _showDetailDialog(AnalysisHistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analysis Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Disease:', item.diseaseResult),
              _buildDetailRow('Confidence:', '${(item.confidence * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('Date:', DateFormat('MMM dd, yyyy • hh:mm a').format(item.timestamp)),
              if (item.recommendations.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(item.recommendations),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _historyService.deleteAnalysis(item.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Analysis deleted from history'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            icon: Icon(Icons.delete),
            label: Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
