import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugLogScreen extends StatefulWidget {
  const DebugLogScreen({super.key});

  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    // Capture print statements
    _startLogging();
  }

  void _startLogging() {
    // Override print to capture logs
    const originalPrint = print;
    print = (Object? object) {
      if (mounted) {
        setState(() {
          _logs.add('${DateTime.now().toString().substring(11, 19)}: $object');
          // Keep only last 100 logs
          if (_logs.length > 100) {
            _logs.removeAt(0);
          }
        });
      }
      originalPrint(object);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _logs.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _logs.clear();
              });
            },
          ),
        ],
      ),
      body: _logs.isEmpty
          ? const Center(child: Text('No logs yet. Try signing in with Google.'))
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isError = log.contains('❌');
                final isSuccess = log.contains('✅');
                return Container(
                  color: isError
                      ? Colors.red.withOpacity(0.1)
                      : isSuccess
                          ? Colors.green.withOpacity(0.1)
                          : null,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isError ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
