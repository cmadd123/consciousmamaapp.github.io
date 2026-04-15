import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class HelpfulDocsPage extends StatefulWidget {
  const HelpfulDocsPage({super.key});

  @override
  State<HelpfulDocsPage> createState() => _HelpfulDocsPageState();
}

class _HelpfulDocsPageState extends State<HelpfulDocsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                      'Helpful Docs',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Andika New Basic',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    // Upload button (admin only — remove later)
                    InkWell(
                      onTap: () => _showUploadSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.upload_rounded, color: FlutterFlowTheme.of(context).primary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // Docs list
              Expanded(
                child: StreamBuilder<List<AppContentRecord>>(
                  stream: queryAppContentRecord(
                    queryBuilder: (q) => q.where('is_published', isEqualTo: true),
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
                                  fontFamily: 'Andika New Basic',
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
                                  fontFamily: 'Andika New Basic',
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

  Widget _buildDocCard(AppContentRecord doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDocDetail(context, doc),
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
                        fontFamily: 'Andika New Basic',
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
                        fontFamily: 'Andika New Basic',
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
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontFamily: 'Andika New Basic'),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
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
                              fontFamily: 'Andika New Basic',
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
                                      fontFamily: 'Andika New Basic',
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
                                    fontFamily: 'Andika New Basic',
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
                                    child: Text(doc.category, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'Andika New Basic')),
                                  ),
                                ],
                                if (doc.readTimeMinutes > 0) ...[
                                  const SizedBox(width: 12),
                                  Text('${doc.readTimeMinutes} min read', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'Andika New Basic')),
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
                                fontFamily: 'Andika New Basic',
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
    final bodyController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedEmoji = '📄';
    final emojis = ['📄', '🧠', '🍎', '💤', '🧒', '💪', '❤️', '🎯', '📋', '🌟', '🏠', '🧹'];

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
                    fontFamily: 'Andika New Basic', fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0,
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

                // Body
                Text('Content', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                const SizedBox(height: 6),
                TextField(
                  controller: bodyController,
                  maxLines: 8,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Andika New Basic'),
                  decoration: InputDecoration(
                    hintText: 'Write or paste the full article here...',
                    filled: true, fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 20),

                // Save
                FFButtonWidget(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) return;
                    HapticFeedback.mediumImpact();

                    final readTime = (bodyController.text.trim().split(' ').length / 200).ceil();

                    await AppContentRecord.collection.add(createAppContentRecordData(
                      title: titleController.text.trim(),
                      author: authorController.text.trim().isNotEmpty ? authorController.text.trim() : 'MomRise',
                      body: bodyController.text.trim(),
                      category: categoryController.text.trim(),
                      emoji: selectedEmoji,
                      isPublished: true,
                      createdAt: DateTime.now(),
                      readTimeMinutes: readTime,
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
                  },
                  text: 'Publish',
                  options: FFButtonOptions(
                    width: double.infinity, height: 52,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Andika New Basic', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, fontFamily: 'Andika New Basic'),
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
