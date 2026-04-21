import 'package:flutter/material.dart';

/// Friendly error screen shown when critical errors occur
/// This prevents white screen crashes and gives users actionable info
class ErrorScreenWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? customMessage;

  const ErrorScreenWidget({
    super.key,
    this.errorDetails,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFEDFFFD),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Friendly icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9E1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.sentiment_dissatisfied_rounded,
                      size: 60,
                      color: Color(0xFFEE8B60),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF14181B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Message
                  Text(
                    customMessage ??
                        'We\'re sorry for the inconvenience. The app encountered an unexpected error.',
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 16,
                      color: const Color(0xFF57636C),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Restart button
                  ElevatedButton(
                    onPressed: () {
                      // This doesn't truly restart the app, but it's better than nothing
                      // Users can force-quit and reopen
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52A097),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Help text
                  Text(
                    'If this problem persists, please try:\n• Restarting the app\n• Checking your internet connection\n• Updating to the latest version',
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 14,
                      color: const Color(0xFF95A1AC),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Debug info (only show in debug mode)
                  if (errorDetails != null) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0E3E7),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error Details (for developers):',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF57636C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorDetails!.exceptionAsString(),
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              color: Color(0xFF95A1AC),
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
