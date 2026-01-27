import '/backend/schema/resource_article_record.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Article Detail Page - Displays full article content
class ArticleDetailWidget extends StatefulWidget {
  const ArticleDetailWidget({
    super.key,
    this.articleId,
  });

  final String? articleId;

  static String routeName = 'articleDetail';
  static String routePath = '/article-detail';

  @override
  State<ArticleDetailWidget> createState() => _ArticleDetailWidgetState();
}

class _ArticleDetailWidgetState extends State<ArticleDetailWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ResourceArticleRecord? _article;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    if (widget.articleId != null) {
      final article = await ResourceArticleRecord.getById(widget.articleId!);
      setState(() {
        _article = article;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Article',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Andika New Basic',
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: FlutterFlowTheme.of(context).primary,
                ),
              )
            : _article == null
                ? _buildNotFound(context)
                : _buildContent(context),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 64.0,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Article not found',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'Andika New Basic',
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag
                if (_article!.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Text(
                      ArticleCategory.displayNames[_article!.category] ?? _article!.category!,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                const SizedBox(height: 12.0),

                // Title
                Text(
                  _article!.title ?? 'Untitled',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Andika New Basic',
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                // Subtitle
                if (_article!.subtitle != null) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    _article!.subtitle!,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'Andika New Basic',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],

                const SizedBox(height: 12.0),

                // Read time
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16.0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${_article!.readTimeMinutes ?? 3} min read',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1.0,
            thickness: 1.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),

          // Content (Markdown)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownBody(
              data: _article!.content ?? '_No content available._',
              styleSheet: MarkdownStyleSheet(
                p: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
                h1: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                h2: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                h3: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                listBullet: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
                blockquote: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Andika New Basic',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontStyle: FontStyle.italic,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 4.0,
                    ),
                  ),
                ),
                blockquotePadding: const EdgeInsets.only(left: 16.0),
              ),
              selectable: true,
            ),
          ),

          // Bottom padding
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }
}
