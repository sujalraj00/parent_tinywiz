import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parent_tinywiz/parent_socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Static cache to persist data across widget recreations
class _AnalyticsDataCache {
  static Map<String, dynamic>? _cachedData;

  static Map<String, dynamic>? get data => _cachedData;

  static void setData(Map<String, dynamic> data) {
    _cachedData = data;
  }
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ParentSocketService _socketService = ParentSocketService();
  Map<String, dynamic>? _usageStats;
  bool _isLoading = true; // Only true initially when no data
  bool _isRefreshing = false; // For manual refresh button
  bool _hasData = false;
  SharedPreferences? _prefs; // Cache SharedPreferences instance

  @override
  void initState() {
    super.initState();
    // First check static cache (fastest)
    if (_AnalyticsDataCache.data != null) {
      print('📊 Analytics: Loading from static cache');
      setState(() {
        _usageStats = _AnalyticsDataCache.data;
        _isLoading = false;
        _hasData = true;
      });
    }
    // Then try to load from SharedPreferences
    _loadSavedData();
    _setupSocketListener();
  }

  Future<void> _loadSavedData() async {
    try {
      // Try to get SharedPreferences with retry
      _prefs = await _getSharedPreferences();

      if (_prefs != null) {
        final savedDataJson = _prefs!.getString('usage_stats_data');

        if (savedDataJson != null && savedDataJson.isNotEmpty) {
          try {
            final savedData = jsonDecode(savedDataJson) as Map<String, dynamic>;
            print(
              '📊 Analytics: Loaded saved usage stats data from SharedPreferences',
            );

            // Also update static cache
            _AnalyticsDataCache.setData(savedData);

            if (mounted) {
              setState(() {
                _usageStats = savedData;
                _isLoading = false; // Don't show loading, we have saved data
                _hasData = true;
              });
            }
            return;
          } catch (e) {
            print('❌ Error parsing saved data: $e');
          }
        }
      }

      print('📊 Analytics: No saved data found');
      if (mounted) {
        setState(() {
          _isLoading = false; // Show "no data" message instead of loading
        });
      }
    } catch (e) {
      print('❌ Error loading saved data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading on error
        });
      }
    }
  }

  Future<SharedPreferences?> _getSharedPreferences() async {
    try {
      // Try with a small delay to ensure platform channels are ready
      await Future.delayed(const Duration(milliseconds: 100));
      return await SharedPreferences.getInstance();
    } catch (e) {
      print('⚠️ SharedPreferences not available: $e');
      // Return null if SharedPreferences fails - we'll use in-memory only
      return null;
    }
  }

  Future<void> _saveData(Map<String, dynamic> data) async {
    try {
      // Ensure we have SharedPreferences instance
      if (_prefs == null) {
        _prefs = await _getSharedPreferences();
      }

      if (_prefs != null) {
        final dataJson = jsonEncode(data);
        final success = await _prefs!.setString('usage_stats_data', dataJson);
        if (success) {
          print('💾 Analytics: Saved usage stats data locally');
        } else {
          print('⚠️ Analytics: Failed to save data (setString returned false)');
        }
      } else {
        print(
          '⚠️ Analytics: SharedPreferences not available, data saved in memory only',
        );
        // Data is already in _usageStats, so it's in memory
        // This will persist until app restart or widget disposal
      }
    } catch (e) {
      print('❌ Error saving data: $e');
      print('   Data will remain in memory until app restart');
      // Data is still in _usageStats, so it's available in memory
    }
  }

  void _setupSocketListener() {
    _socketService.onChildUsageStats = (data) {
      if (!mounted) return;

      try {
        print('📊 Analytics: Received usage stats data');
        print('   Data type: ${data.runtimeType}');

        // Extract the actual usage stats from the nested structure
        // Data structure: {childId: ..., usageStats: [{summary: ..., apps: ...}]}
        Map<String, dynamic>? extractedStats;

        final dataMap = data as Map?;
        if (dataMap != null) {
          print('   Data keys: ${dataMap.keys.toList()}');
          final usageStatsArray = dataMap['usageStats'];
          if (usageStatsArray is List && usageStatsArray.isNotEmpty) {
            // Get the first element from the usageStats array
            final firstElement = usageStatsArray[0];
            if (firstElement is Map) {
              extractedStats = Map<String, dynamic>.from(firstElement);
              print('   ✅ Extracted stats from usageStats array');
            }
          } else if (dataMap.containsKey('summary') &&
              dataMap.containsKey('apps')) {
            // Direct structure (fallback)
            extractedStats = Map<String, dynamic>.from(dataMap);
            print('   ✅ Using direct structure');
          }
        }

        if (extractedStats != null) {
          print('   ✅ Setting usage stats with summary and apps');

          // Save to static cache first (immediate, always works)
          _AnalyticsDataCache.setData(extractedStats);

          // Try to save to SharedPreferences (may fail, but cache will work)
          _saveData(extractedStats);

          setState(() {
            _usageStats = extractedStats;
            _isLoading = false; // Stop initial loading
            _isRefreshing = false; // Stop refresh indicator
            _hasData = true;
          });
        } else {
          print('   ❌ Could not extract usage stats from data structure');
        }
      } catch (e, stackTrace) {
        // Widget might be disposed, ignore
        print('❌ Error updating analytics state: $e');
        print('   Stack trace: $stackTrace');
      }
    };
  }

  @override
  void dispose() {
    // Clear the callback to prevent memory leaks
    _socketService.onChildUsageStats = null;
    super.dispose();
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Usage Analytics'),
        actions: [
          if (_hasData)
            IconButton(
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
              onPressed: _isRefreshing
                  ? null
                  : () {
                      // Manual refresh - just show loading on button
                      // Data will update automatically when new websocket data arrives
                      setState(() {
                        _isRefreshing = true;
                      });
                      // Reset after a short delay (websocket will update data)
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _isRefreshing = false;
                          });
                        }
                      });
                    },
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading && !_hasData && _usageStats == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Waiting for usage data...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _usageStats == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No usage data available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usage stats will appear here when received',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Section
                  _buildSummarySection(),
                  const SizedBox(height: 24),
                  // Apps List Section
                  _buildAppsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummarySection() {
    final summary = _usageStats!['summary'] as Map<String, dynamic>?;
    if (summary == null) return const SizedBox.shrink();

    final totalApps = summary['totalApps'] as int? ?? 0;
    final totalUsageTime = summary['totalUsageTime'] as int? ?? 0;
    final socialMediaApps = summary['socialMediaApps'] as int? ?? 0;
    final timestamp = summary['timestamp'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Apps',
                totalApps.toString(),
                Icons.apps,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Usage',
                _formatTime(totalUsageTime),
                Icons.access_time,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Social Media Apps',
          socialMediaApps.toString(),
          Icons.people,
          Colors.orange,
          fullWidth: true,
        ),
        if (timestamp != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${_formatTimestamp(timestamp)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsSection() {
    final apps = _usageStats!['apps'] as List<dynamic>?;
    if (apps == null || apps.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort apps by usage time (descending)
    final sortedApps = List<Map<String, dynamic>>.from(apps)
      ..sort((a, b) {
        final timeA = a['totalTimeInForeground'] as int? ?? 0;
        final timeB = b['totalTimeInForeground'] as int? ?? 0;
        return timeB.compareTo(timeA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App Usage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedApps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildAppCard(sortedApps[index]);
          },
        ),
      ],
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app) {
    final appName = app['appName'] as String? ?? 'Unknown App';
    final packageName = app['packageName'] as String? ?? '';
    final totalTime = app['totalTimeInForeground'] as int? ?? 0;
    final formattedTime =
        app['formattedTime'] as String? ?? _formatDuration(totalTime);
    final usagePercentage = (app['usagePercentage'] as num?)?.toDouble() ?? 0.0;
    final isSocialMedia = app['isSocialMedia'] as bool? ?? false;
    final lastTimeUsed = app['lastTimeUsed'] as int?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: isSocialMedia
            ? Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSocialMedia
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSocialMedia ? Icons.people : Icons.apps,
                  color: isSocialMedia ? Colors.orange : Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSocialMedia)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Social',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      packageName,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Usage time and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage Time',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Percentage',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${usagePercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usagePercentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                isSocialMedia ? Colors.orange : Colors.blue,
              ),
            ),
          ),
          if (lastTimeUsed != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Last used: ${_formatLastUsed(lastTimeUsed)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return isoString;
    }
  }

  String _formatLastUsed(int milliseconds) {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
