import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parent_tinywiz/parent_socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasData = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    if (_AnalyticsDataCache.data != null) {
      setState(() {
        _usageStats = _AnalyticsDataCache.data;
        _isLoading = false;
        _hasData = true;
      });
    }
    _loadSavedData();
    _setupSocketListener();
  }

  Future<void> _loadSavedData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      _prefs = await SharedPreferences.getInstance();

      if (_prefs != null) {
        final savedDataJson = _prefs!.getString('usage_stats_data');
        if (savedDataJson != null && savedDataJson.isNotEmpty) {
          try {
            final savedData = jsonDecode(savedDataJson) as Map<String, dynamic>;
            _AnalyticsDataCache.setData(savedData);
            if (mounted) {
              setState(() {
                _usageStats = savedData;
                _isLoading = false;
                _hasData = true;
              });
            }
            return;
          } catch (_) {}
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData(Map<String, dynamic> data) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (_prefs != null) {
        await _prefs!.setString('usage_stats_data', jsonEncode(data));
      }
    } catch (_) {}
  }

  void _setupSocketListener() {
    _socketService.onChildUsageStats = (data) {
      if (!mounted) return;
      try {
        Map<String, dynamic>? extractedStats;
        final dataMap = data as Map?;
        if (dataMap != null) {
          final usageStatsArray = dataMap['usageStats'];
          if (usageStatsArray is List && usageStatsArray.isNotEmpty) {
            final firstElement = usageStatsArray[0];
            if (firstElement is Map) extractedStats = Map<String, dynamic>.from(firstElement);
          } else if (dataMap.containsKey('summary') && dataMap.containsKey('apps')) {
            extractedStats = Map<String, dynamic>.from(dataMap);
          }
        }

        if (extractedStats != null) {
          _AnalyticsDataCache.setData(extractedStats);
          _saveData(extractedStats);
          setState(() {
            _usageStats = extractedStats;
            _isLoading = false;
            _isRefreshing = false;
            _hasData = true;
          });
        }
      } catch (_) {}
    };
  }

  @override
  void dispose() {
    _socketService.onChildUsageStats = null;
    super.dispose();
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  String _formatTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m';
    return '${seconds}s';
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF252530),
      highlightColor: const Color(0xFF353540),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 24, width: 120, color: Colors.white, margin: const EdgeInsets.only(bottom: 16)),
          Row(
            children: [
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 32),
          Container(height: 24, width: 150, color: Colors.white, margin: const EdgeInsets.only(bottom: 16)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final summary = _usageStats!['summary'] as Map<String, dynamic>?;
    if (summary == null) return const SizedBox.shrink();

    final totalApps = summary['totalApps'] as int? ?? 0;
    final totalUsageTime = summary['totalUsageTime'] as int? ?? 0;
    final socialMediaApps = summary['socialMediaApps'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Apps',
                totalApps.toString(),
                Icons.grid_view_rounded,
                const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Time',
                _formatTime(totalUsageTime),
                Icons.access_time_rounded,
                Colors.purpleAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Social Media Apps',
          socialMediaApps.toString(),
          Icons.people_alt_rounded,
          Colors.orangeAccent,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsSection() {
    final apps = _usageStats!['apps'] as List<dynamic>?;
    if (apps == null || apps.isEmpty) return const SizedBox.shrink();

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
          'Detailed Usage',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedApps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildAppCard(sortedApps[index]),
        ),
      ],
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app) {
    final appName = app['appName'] as String? ?? 'Unknown App';
    final packageName = app['packageName'] as String? ?? '';
    final totalTime = app['totalTimeInForeground'] as int? ?? 0;
    final formattedTime = app['formattedTime'] as String? ?? _formatDuration(totalTime);
    final usagePercentage = (app['usagePercentage'] as num?)?.toDouble() ?? 0.0;
    final isSocialMedia = app['isSocialMedia'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSocialMedia ? Colors.orangeAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSocialMedia ? Colors.orangeAccent.withOpacity(0.15) : const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSocialMedia ? Icons.chat_bubble_rounded : Icons.app_shortcut_rounded,
                  color: isSocialMedia ? Colors.orangeAccent : const Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      packageName,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${usagePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usagePercentage / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFF252530),
              valueColor: AlwaysStoppedAnimation<Color>(
                isSocialMedia ? Colors.orangeAccent : const Color(0xFF6C63FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF))),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing
                ? null
                : () {
                    setState(() => _isRefreshing = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isRefreshing = false);
                    });
                  },
          ),
        ],
      ),
      body: _isLoading && !_hasData
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: _buildShimmerLoading(),
            )
          : _usageStats == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: const Color(0xFF1C1C24), shape: BoxShape.circle),
                        child: Icon(Icons.analytics_rounded, size: 64, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Data Available',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'re waiting for usage stats to sync.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummarySection(),
                      const SizedBox(height: 32),
                      _buildAppsSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}
