import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard için
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hand_speak/services/storage_service.dart';
import 'package:hand_speak/debug/storage_test_helper.dart';

class FirebaseStorageDiagnosticWidget extends StatefulWidget {
  const FirebaseStorageDiagnosticWidget({super.key});

  @override
  State<FirebaseStorageDiagnosticWidget> createState() => _FirebaseStorageDiagnosticWidgetState();
}

class _FirebaseStorageDiagnosticWidgetState extends State<FirebaseStorageDiagnosticWidget> {
  final List<String> _diagnosticResults = [];
  bool _isRunning = false;
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Diagnostics'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Storage Diagnostic Tool',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool helps diagnose Firebase Storage authorization issues.',
                      style: TextStyle(color: Colors.grey),
                    ),                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isRunning ? null : _runDiagnostics,
                          child: _isRunning 
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Running...'),
                                  ],
                                )
                              : const Text('Run Diagnostics'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isRunning ? null : _runAutomatedTests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Run Auto Tests'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _clearResults,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Diagnostic Results:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Copy button
                              IconButton(
                                onPressed: _diagnosticResults.isEmpty ? null : _copyResults,
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: 'Copy results to clipboard',
                                visualDensity: VisualDensity.compact,
                              ),
                              // Save to file button (bonus)
                              IconButton(
                                onPressed: _diagnosticResults.isEmpty ? null : _saveResults,
                                icon: const Icon(Icons.save_alt, size: 18),
                                tooltip: 'Save results to file',
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _diagnosticResults.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No diagnostics run yet.\nClick "Run Diagnostics" to start.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _diagnosticResults.length,                                  itemBuilder: (context, index) {
                                    final result = _diagnosticResults[index];
                                    Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
                                    FontWeight fontWeight = FontWeight.normal;
                                    
                                    // Better color coding with theme awareness
                                    if (result.contains('✅') || result.contains('passed') || result.contains('successful')) {
                                      textColor = Colors.green.shade700;
                                      fontWeight = FontWeight.w500;
                                    } else if (result.contains('❌') || result.contains('failed') || result.contains('unauthorized')) {
                                      textColor = Colors.red.shade700;
                                      fontWeight = FontWeight.w600;
                                    } else if (result.contains('⚠️') || result.contains('warning') || result.contains('denied')) {
                                      textColor = Colors.orange.shade700;
                                      fontWeight = FontWeight.w500;
                                    } else if (result.contains('🔍') || result.contains('🔬') || result.contains('Testing') || result.contains('Running')) {
                                      textColor = Colors.blue.shade700;
                                      fontWeight = FontWeight.w500;
                                    } else if (result.contains('🏁') || result.contains('completed') || result.contains('===')) {
                                      textColor = Colors.purple.shade700;
                                      fontWeight = FontWeight.w600;
                                    } else if (result.contains('User:') || result.contains('Token:') || result.contains('Path:')) {
                                      textColor = Colors.indigo.shade600;
                                      fontWeight = FontWeight.w500;
                                    }
                                    
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getBackgroundColor(result),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        result,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: fontWeight,
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.yellow.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Quick Fixes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('• Check Firebase Storage Rules in Firebase Console'),
                    const Text('• Verify user authentication status'),
                    const Text('• Ensure internet connectivity'),
                    const Text('• Check file size limits (5MB for images, 50MB for videos)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addResult(String message) {
    setState(() {
      _diagnosticResults.add('${DateTime.now().toString().substring(11, 19)} $message');
    });
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _diagnosticResults.clear();
    });

    _addResult('🔍 Starting Firebase Storage diagnostics...');

    try {
      // Check 1: Firebase Auth Status
      _addResult('🔍 Checking Firebase Authentication...');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _addResult('✅ User authenticated: ${user.uid}');
        _addResult('   Email: ${user.email ?? "No email"}');
        _addResult('   Display Name: ${user.displayName ?? "No display name"}');
        
        // Check ID Token
        try {
          final token = await user.getIdToken();
          _addResult('✅ ID Token obtained (length: ${token?.length ?? 0})');
        } catch (e) {
          _addResult('❌ Failed to get ID Token: $e');
        }
      } else {
        _addResult('❌ No user authenticated');
        _addResult('⚠️  Storage operations require authentication');
      }

      // Check 2: Firebase Storage Connection
      _addResult('🔍 Testing Firebase Storage connection...');
      try {
        final storage = FirebaseStorage.instance;
        final rootRef = storage.ref();
        
        // Test basic connection
        await rootRef.listAll();
        _addResult('✅ Firebase Storage connection successful');
      } catch (e) {
        if (e.toString().contains('unauthorized') || e.toString().contains('permission')) {
          _addResult('⚠️  Storage connection blocked by security rules (expected)');
        } else {
          _addResult('❌ Storage connection failed: $e');
        }
      }

      // Check 3: Storage Permission Test
      if (user != null) {
        _addResult('🔍 Testing storage permissions...');
        try {
          final hasPermission = await _storageService.testStoragePermissions();
          if (hasPermission) {
            _addResult('✅ Storage permissions test passed');
          } else {
            _addResult('❌ Storage permissions test failed');
          }
        } catch (e) {
          _addResult('❌ Permission test error: $e');
        }
      }

      // Check 4: Storage Rules Analysis
      _addResult('🔍 Analyzing potential storage rules issues...');
      if (user != null) {
        final userId = user.uid;
        _addResult('   Expected upload path: profile_images/$userId/profile.jpg');
        _addResult('   Expected video path: videos/$userId/{filename}.mp4');
        _addResult('   Required auth: request.auth.uid == "$userId"');
      }

      // Check 5: Network connectivity
      _addResult('🔍 Checking network connectivity...');
      try {
        // Simple ping test to Firebase Storage
        final storage = FirebaseStorage.instance;
        final testRef = storage.ref().child('test');
        await testRef.getDownloadURL();
        _addResult('✅ Network connectivity to Firebase Storage confirmed');
      } catch (e) {
        if (e.toString().contains('object-not-found')) {
          _addResult('✅ Network connectivity confirmed (object not found is expected)');
        } else {
          _addResult('❌ Network connectivity issue: $e');
        }
      }

      _addResult('🔍 Diagnostics completed');

    } catch (e) {
      _addResult('❌ Diagnostic error: $e');    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  // Run automated tests using StorageTestHelper
  Future<void> _runAutomatedTests() async {
    setState(() {
      _isRunning = true;
      _diagnosticResults.clear();
    });

    try {
      final testResults = await StorageTestHelper.runAllTests();
      
      setState(() {
        _diagnosticResults.addAll(testResults);
      });
    } catch (e) {
      setState(() {
        _diagnosticResults.add('❌ Automated tests failed: $e');
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }
  // Clear diagnostic results
  void _clearResults() {
    setState(() {
      _diagnosticResults.clear();
    });
  }

  // Copy results to clipboard
  Future<void> _copyResults() async {
    if (_diagnosticResults.isEmpty) return;
    
    final resultsText = _formatResultsForExport();
    
    try {
      await Clipboard.setData(ClipboardData(text: resultsText));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Results copied to clipboard!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to copy: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Save results to file (placeholder - could be enhanced)
  Future<void> _saveResults() async {
    if (_diagnosticResults.isEmpty) return;
    
    // For now, just copy to clipboard with formatted text
    await _copyResults();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💾 Results copied to clipboard (file save coming soon)'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Format results for export
  String _formatResultsForExport() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('🔍 Firebase Storage Diagnostic Results');
    buffer.writeln('📅 Date: ${DateTime.now().toString()}');
    buffer.writeln('📱 App: Hand Speak');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    // Results
    for (int i = 0; i < _diagnosticResults.length; i++) {
      final result = _diagnosticResults[i];
      buffer.writeln('${i + 1}. $result');
    }
    
    // Footer
    buffer.writeln();
    buffer.writeln('=' * 50);
    buffer.writeln('📋 Copy this text to share diagnostic results');
    buffer.writeln('🔧 For support, include this information when reporting issues');
      return buffer.toString();
  }

  // Helper method to get background color for different result types
  Color _getBackgroundColor(String result) {
    if (result.contains('❌') || result.contains('failed')) {
      return Colors.red.shade50;
    } else if (result.contains('✅') || result.contains('passed')) {
      return Colors.green.shade50;
    } else if (result.contains('⚠️') || result.contains('warning')) {
      return Colors.orange.shade50;
    } else if (result.contains('🔍') || result.contains('🔬')) {
      return Colors.blue.shade50;
    } else if (result.contains('🏁') || result.contains('===')) {
      return Colors.purple.shade50;
    }
    return Colors.transparent;
  }
}
