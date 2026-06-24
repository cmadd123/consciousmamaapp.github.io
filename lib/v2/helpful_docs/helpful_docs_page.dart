import 'dart:io';  // For File picker
import 'package:flutter/material.dart';
import '/app_state.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:provider/provider.dart';
import '/v2/creator/creator_theme_notifier.dart';
import '/v2/creator/creator_theme_wrapper.dart';

class HelpfulDocsPage extends StatefulWidget {
  const HelpfulDocsPage({super.key});

  @override
  State<HelpfulDocsPage> createState() => _HelpfulDocsPageState();
}

class _HelpfulDocsPageState extends State<HelpfulDocsPage> {
  @override
  Widget build(BuildContext context) {
    // Only show docs uploaded by the follower's active creator. If no
    // active creator, the list is empty — helpful docs are a creator-
    // curated feature, not a global MomRise library.
    final notifier = Provider.of<CreatorThemeNotifier>(context);
    final creator = notifier.activeCreator;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CreatorThemedBackground(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, color: FlutterFlowTheme.of(context).primaryText),
                    ),
                    Text(
                      creator != null ? 'From ${creator.name}' : 'Helpful Docs',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    // Keep layout balanced; uploads now live on the web dashboard.
                    const SizedBox(width: 34),
                  ],
                ),
              ),

              // Docs list — scoped to the active creator
              Expanded(
                child: StreamBuilder<List<AppContentRecord>>(
                  stream: creator == null
                      ? Stream.value(const <AppContentRecord>[])
                      : queryAppContentRecord(
                          queryBuilder: (q) => q
                              .where('creator_ref', isEqualTo: creator.reference)
                              .where('is_published', isEqualTo: true),
                        ),
                  builder: (context, snapshot) {
                    final docs = snapshot.data ?? [];

                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary),
                        ),
                      );
                    }

                    if (docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No docs yet',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Helpful articles and guides will appear here.',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: const Color(0xFF999999),
                                  fontSize: 13,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, index) => _buildDocCard(docs[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(AppContentRecord doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete doc?'),
        content: Text('Remove "${doc.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      if (doc.hasPdfUrl() && doc.pdfUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(doc.pdfUrl).delete();
        } catch (_) {}
      }
      await doc.reference.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doc deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Widget _buildDocCard(AppContentRecord doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDocDetail(context, doc),
        onLongPress: () => _confirmAndDelete(doc),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              // Emoji
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(doc.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              // Title + author
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'by ${doc.author}',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              // Category chip
              if (doc.hasCategory() && doc.category.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    doc.category,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontFamily: FFAppState().currentFontFamily),
                  ),
                ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _confirmAndDelete(doc),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full doc detail view
  void _showDocDetail(BuildContext context, AppContentRecord doc) {
    if (doc.hasPdfUrl()) {
      _showPdfViewer(context, doc);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: CreatorThemedBackground(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back, color: FlutterFlowTheme.of(context).primaryText),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            doc.title,
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji + title
                            Row(
                              children: [
                                Text(doc.emoji, style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    doc.title,
                                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Author + category
                            Row(
                              children: [
                                Text(
                                  'by ${doc.author}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: FFAppState().currentFontFamily,
                                  ),
                                ),
                                if (doc.hasCategory()) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(doc.category, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: FFAppState().currentFontFamily)),
                                  ),
                                ],
                                if (doc.readTimeMinutes > 0) ...[
                                  const SizedBox(width: 12),
                                  Text('${doc.readTimeMinutes} min read', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: FFAppState().currentFontFamily)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),
                            // Body text
                            Text(
                              doc.body,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 15,
                                letterSpacing: 0,
                                lineHeight: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Upload sheet (admin only — remove later)
  void _showUploadSheet(BuildContext context) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedEmoji = '📄';
    final emojis = ['📄', '🧠', '🍎', '💤', '🧒', '💪', '❤️', '🎯', '📋', '🌟', '🏠', '🧹'];
    PlatformFile? selectedFile;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Center(
                  child: Text('Upload Doc', style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FFAppState().currentFontFamily, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0,
                  )),
                ),
                const SizedBox(height: 20),

                // Emoji
                Text('Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setSheetState(() => selectedEmoji = e),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: selectedEmoji == e ? FlutterFlowTheme.of(context).primary.withOpacity(0.15) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: selectedEmoji == e ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2) : null,
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 14),

                // Title
                _buildField('Title', titleController, 'e.g., What to do when your child says no'),
                _buildField('Author', authorController, 'e.g., Haley'),
                _buildField('Category', categoryController, 'e.g., Behavior, Nutrition, Sleep'),

                // File picker
                Text('Document', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final picked = result.files.first;
                      if (!picked.name.toLowerCase().endsWith('.pdf')) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a PDF file')),
                          );
                        }
                        return;
                      }
                      setSheetState(() => selectedFile = picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: selectedFile != null
                          ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2)
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedFile != null ? Icons.picture_as_pdf : Icons.upload_file,
                          color: selectedFile != null ? Colors.red : Colors.grey.shade500,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedFile != null ? selectedFile!.name : 'Tap to select a PDF',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: selectedFile != null ? Colors.black : Colors.grey.shade600,
                                  fontFamily: FFAppState().currentFontFamily,
                                ),
                              ),
                              if (selectedFile != null)
                                Text(
                                  '${(selectedFile!.size / 1024).toStringAsFixed(0)} KB',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                            ],
                          ),
                        ),
                        if (selectedFile != null)
                          GestureDetector(
                            onTap: () => setSheetState(() => selectedFile = null),
                            child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save
                FFButtonWidget(
                  onPressed: isUploading ? null : () async {
                    if (titleController.text.trim().isEmpty || selectedFile == null) return;
                    setSheetState(() => isUploading = true);
                    HapticFeedback.mediumImpact();

                    try {
                      // Upload PDF to Firebase Storage. Path scoped to the
                      // uploader's uid so the storage rule can enforce
                      // ownership. 10MB cap + application/pdf enforced
                      // server-side. See firebase/storage.rules.
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sign in required to upload.')),
                        );
                        setSheetState(() => isUploading = false);
                        return;
                      }
                      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.name}';
                      final storageRef = FirebaseStorage.instance.ref().child('helpful_docs/$uid/$fileName');

                      final file = File(selectedFile!.path!);
                      final uploadTask = await storageRef.putFile(file);
                      final downloadUrl = await uploadTask.ref.getDownloadURL();

                      await AppContentRecord.collection.add(createAppContentRecordData(
                        title: titleController.text.trim(),
                        author: authorController.text.trim().isNotEmpty ? authorController.text.trim() : 'MomRise',
                        category: categoryController.text.trim(),
                        emoji: selectedEmoji,
                        isPublished: true,
                        createdAt: DateTime.now(),
                        pdfUrl: downloadUrl,
                        contentType: 'pdf',
                      ));

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Doc uploaded!'),
                            backgroundColor: FlutterFlowTheme.of(context).primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    } catch (e) {
                      setSheetState(() => isUploading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  text: isUploading ? 'Uploading...' : 'Publish',
                  options: FFButtonOptions(
                    width: double.infinity, height: 52,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: FFAppState().currentFontFamily, color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    disabledColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Open PDF in-app
  void _showPdfViewer(BuildContext context, AppContentRecord doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InAppPdfScreen(doc: doc),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, fontFamily: FFAppState().currentFontFamily),
          decoration: InputDecoration(
            hintText: hint,
            filled: true, fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
class _InAppPdfScreen extends StatefulWidget {
  const _InAppPdfScreen({required this.doc});
  final AppContentRecord doc;

  @override
  State<_InAppPdfScreen> createState() => _InAppPdfScreenState();
}

class _InAppPdfScreenState extends State<_InAppPdfScreen> {
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    try {
      final res = await http.get(Uri.parse(widget.doc.pdfUrl));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/doc_${widget.doc.reference.id}.pdf');
      await file.writeAsBytes(res.bodyBytes, flush: true);
      if (mounted) setState(() => _localPath = file.path);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          widget.doc.title,
          style: TextStyle(
            fontFamily: FFAppState().currentFontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load PDF: $_error', textAlign: TextAlign.center),
              ),
            )
          : _localPath == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PDFView(
                      filePath: _localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                    ),
                  ),
                ),
    );
  }
}
// In-app PDF viewing can be added later with flutter_pdfview when disk space allows
