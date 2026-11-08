import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/* --------------------------------------------------------- plain-text pages */

/// A block in a content page body, mirroring `frontend/src/utils/content.ts`.
enum ContentBlockKind { paragraph, unorderedList, orderedList, note }

class ContentBlock {
  const ContentBlock._({
    required this.kind,
    required this.text,
    this.items = const [],
  });

  final ContentBlockKind kind;
  final String text;
  final List<String> items;
}

/// Parse the plain-text bodies stored on public content pages.
///
/// Conventions match the web renderer exactly: a blank line separates blocks,
/// `- ` / `* ` starts an unordered list, `1. ` / `1) ` an ordered list, `> ` a
/// note, and consecutive paragraph lines are joined with a space.
List<ContentBlock> parseContentBlocks(String body) {
  final blocks = <ContentBlock>[];
  var mode = ContentBlockKind.paragraph;
  var hasMode = false;
  var buffer = <String>[];

  void flush() {
    if (buffer.isEmpty) {
      hasMode = false;
      return;
    }
    final text = buffer.join(' ');
    switch (mode) {
      case ContentBlockKind.unorderedList:
        blocks.add(
          ContentBlock._(
            kind: ContentBlockKind.unorderedList,
            text: '',
            items: List<String>.unmodifiable(buffer),
          ),
        );
        break;
      case ContentBlockKind.orderedList:
        blocks.add(
          ContentBlock._(
            kind: ContentBlockKind.orderedList,
            text: '',
            items: List<String>.unmodifiable(buffer),
          ),
        );
        break;
      case ContentBlockKind.note:
        blocks.add(
          ContentBlock._(kind: ContentBlockKind.note, text: text),
        );
        break;
      case ContentBlockKind.paragraph:
        blocks.add(
          ContentBlock._(kind: ContentBlockKind.paragraph, text: text),
        );
        break;
    }
    buffer = <String>[];
    hasMode = false;
  }

  final unordered = RegExp(r'^[-*]\s+');
  final ordered = RegExp(r'^\d+[.)]\s+');
  final note = RegExp(r'^>\s?');

  for (final raw in body.replaceAll(RegExp(r'\r\n?'), '\n').split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) {
      flush();
      continue;
    }

    if (unordered.hasMatch(line)) {
      if (!hasMode || mode != ContentBlockKind.unorderedList) flush();
      mode = ContentBlockKind.unorderedList;
      hasMode = true;
      buffer.add(line.replaceFirst(unordered, ''));
    } else if (ordered.hasMatch(line)) {
      if (!hasMode || mode != ContentBlockKind.orderedList) flush();
      mode = ContentBlockKind.orderedList;
      hasMode = true;
      buffer.add(line.replaceFirst(ordered, ''));
    } else if (note.hasMatch(line)) {
      if (!hasMode || mode != ContentBlockKind.note) flush();
      mode = ContentBlockKind.note;
      hasMode = true;
      buffer.add(line.replaceFirst(note, ''));
    } else {
      if (!hasMode || mode != ContentBlockKind.paragraph) flush();
      mode = ContentBlockKind.paragraph;
      hasMode = true;
      buffer.add(line);
    }
  }
  flush();

  return blocks;
}

class LabeledItem {
  const LabeledItem({required this.title, required this.description});

  final String title;
  final String description;
}

/// Parse a `cards` or `steps` body: one item per non-empty line, split on the
/// first `: ` into a title and a description.
List<LabeledItem> parseLabeledItems(String body) {
  return body
      .replaceAll(RegExp(r'\r\n?'), '\n')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) {
    final separator = line.indexOf(': ');
    if (separator == -1) {
      return LabeledItem(title: line, description: '');
    }
    return LabeledItem(
      title: line.substring(0, separator).trim(),
      description: line.substring(separator + 2).trim(),
    );
  }).toList();
}

/// Render a content-page body with the same visual hierarchy as the web page.
class ContentBlocksView extends StatelessWidget {
  const ContentBlocksView({super.key, required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final blocks = parseContentBlocks(body);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: switch (block.kind) {
              ContentBlockKind.paragraph => Text(
                  block.text,
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.65,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ContentBlockKind.note => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.tint(scheme.primary),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 20, color: scheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          block.text,
                          style: textTheme.bodyMedium?.copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ContentBlockKind.unorderedList => _list(
                  context,
                  block.items,
                  ordered: false,
                ),
              ContentBlockKind.orderedList => _list(
                  context,
                  block.items,
                  ordered: true,
                ),
            },
          ),
      ],
    );
  }

  Widget _list(
    BuildContext context,
    List<String> items, {
    required bool ordered,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    ordered ? '${index + 1}.' : '•',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    items[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/* ------------------------------------------------------------ rich HTML */

enum HtmlBlockKind { paragraph, heading, quote, code, listItem, image, divider, caption }

class HtmlBlock {
  const HtmlBlock._({
    required this.kind,
    this.html = '',
    this.text = '',
    this.src,
    this.alt = '',
  });

  final HtmlBlockKind kind;
  final String html;
  final String text;
  final String? src;
  final String alt;
}

const _blockTags = <String>{
  'p',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'blockquote',
  'pre',
  'li',
  'figcaption',
  'div',
};

/// Split sanitized newsletter HTML into renderable blocks.
///
/// The backend already drops scripts, styles and event handlers. This parser is
/// deliberately conservative: it only understands the tags the editor emits, and
/// anything it does not understand is flattened to its text. That is what makes
/// it safe to render without a WebView.
List<HtmlBlock> parseHtmlBlocks(String html) {
  final source = html
      .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');

  final blocks = <HtmlBlock>[];
  final buffer = StringBuffer();
  String? current;
  var ordered = false;
  var counter = 0;

  void flush() {
    final text = buffer.toString();
    buffer.clear();
    if (text.trim().isEmpty) {
      current = null;
      return;
    }
    switch (current) {
      case 'h1':
      case 'h2':
        blocks.add(HtmlBlock._(kind: HtmlBlockKind.heading, html: text, text: '2'));
        break;
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        blocks.add(HtmlBlock._(kind: HtmlBlockKind.heading, html: text, text: '3'));
        break;
      case 'blockquote':
        blocks.add(HtmlBlock._(kind: HtmlBlockKind.quote, html: text));
        break;
      case 'pre':
        blocks.add(HtmlBlock._(kind: HtmlBlockKind.code, html: text));
        break;
      case 'li':
        blocks.add(HtmlBlock._(kind: HtmlBlockKind.listItem, html: text));
        break;
      case 'figcaption':
        blocks.add(HtmlBlock._(kind: HtmlBlockKind.caption, html: text));
        break;
      default:
        blocks.add(HtmlBlock._(kind: HtmlBlockKind.paragraph, html: text));
        break;
    }
    current = null;
  }

  final tagPattern = RegExp(r'<[^>]*>');
  var index = 0;
  for (final match in tagPattern.allMatches(source)) {
    buffer.write(source.substring(index, match.start));
    final tag = match.group(0)!;
    final name = RegExp(r'^</?\s*([a-zA-Z0-9]+)')
        .firstMatch(tag)
        ?.group(1)
        ?.toLowerCase();
    final closing = tag.startsWith('</');

    if (name == 'img') {
      flush();
      final src = RegExp(r'''src\s*=\s*["']([^"']+)["']''')
          .firstMatch(tag)
          ?.group(1);
      final alt = RegExp(r'''alt\s*=\s*["']([^"']*)["']''')
              .firstMatch(tag)
              ?.group(1) ??
          '';
      if (src != null && src.isNotEmpty) {
        blocks.add(
          HtmlBlock._(
            kind: HtmlBlockKind.image,
            src: src,
            alt: decodeHtmlEntities(alt),
          ),
        );
      }
    } else if (name == 'hr') {
      flush();
      blocks.add(const HtmlBlock._(kind: HtmlBlockKind.divider));
    } else if (name == 'ul' || name == 'ol') {
      flush();
      ordered = name == 'ol';
      counter = 0;
    } else if (name == 'figure') {
      // Structural wrapper: the image and caption are their own blocks.
      flush();
    } else if (name != null && _blockTags.contains(name)) {
      if (closing) {
        flush();
      } else {
        flush();
        current = name;
        if (name == 'li') {
          if (ordered) {
            counter++;
            buffer.write('$counter. ');
          } else {
            buffer.write('• ');
          }
        }
      }
    } else if (name == 'br') {
      buffer.write('\n');
    } else {
      // Keep inline markup for the inline parser.
      buffer.write(tag);
    }
    index = match.end;
  }
  buffer.write(source.substring(index));
  flush();

  return blocks;
}

/// Decode the small entity set the editor can produce.
String decodeHtmlEntities(String input) {
  var value = input
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–')
      .replaceAll('&hellip;', '…');
  value = value.replaceAllMapped(
    RegExp(r'&#(\d+);'),
    (match) => String.fromCharCode(int.tryParse(match.group(1) ?? '') ?? 0),
  );
  return value;
}

/// A dependency-free renderer for the newsletter's sanitized HTML.
///
/// Links render as styled text rather than opening a browser: the app does not
/// ship a URL launcher, and a dead-looking link is worse than honest emphasis.
class SanitizedHtml extends StatelessWidget {
  const SanitizedHtml({super.key, required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final blocks = parseHtmlBlocks(html);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: switch (block.kind) {
              HtmlBlockKind.heading => Text.rich(
                  TextSpan(
                    children: parseHtmlInline(
                      block.html,
                      theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ) ??
                          const TextStyle(),
                      linkColor: scheme.primary,
                    ),
                  ),
                ),
              HtmlBlockKind.quote => Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(color: scheme.primary, width: 3),
                    ),
                    color: AppColors.tint(scheme.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: parseHtmlInline(
                        block.html,
                        theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ) ??
                            const TextStyle(),
                        linkColor: scheme.primary,
                      ),
                    ),
                  ),
                ),
              HtmlBlockKind.code => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      decodeHtmlEntities(block.html.replaceAll(RegExp(r'<[^>]*>'), '')),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              HtmlBlockKind.listItem => Text.rich(
                  TextSpan(
                    children: parseHtmlInline(
                      block.html,
                      theme.textTheme.bodyLarge?.copyWith(
                            height: 1.65,
                            color: scheme.onSurfaceVariant,
                          ) ??
                          const TextStyle(),
                      linkColor: scheme.primary,
                    ),
                  ),
                ),
              HtmlBlockKind.image => _image(context, block),
              HtmlBlockKind.divider => Divider(
                  color: scheme.outline,
                  height: 28,
                ),
              HtmlBlockKind.caption => Text(
                  decodeHtmlEntities(
                    block.html.replaceAll(RegExp(r'<[^>]*>'), ''),
                  ).trim(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              HtmlBlockKind.paragraph => Text.rich(
                  TextSpan(
                    children: parseHtmlInline(
                      block.html,
                      theme.textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            color: scheme.onSurfaceVariant,
                          ) ??
                          const TextStyle(),
                      linkColor: scheme.primary,
                    ),
                  ),
                ),
            },
          ),
      ],
    );
  }

  Widget _image(BuildContext context, HtmlBlock block) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CachedNetworkImage(
        imageUrl: block.src!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          height: 160,
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

/// Convert inline HTML to styled spans. Unknown tags are ignored; their text
/// survives, which is exactly the sanitizer's own "clean, don't reject" rule.
List<InlineSpan> parseHtmlInline(
  String html,
  TextStyle base, {
  required Color linkColor,
}) {
  final spans = <InlineSpan>[];
  final styles = <TextStyle>[base];

  void addText(String text) {
    if (text.isEmpty) return;
    spans.add(
      TextSpan(
        text: decodeHtmlEntities(text),
        style: styles.isEmpty ? base : styles.last,
      ),
    );
  }

  void push(TextStyle style) => styles.add(style);
  void pop() {
    if (styles.length > 1) styles.removeLast();
  }

  final pattern = RegExp(r'<[^>]*>');
  var index = 0;
  for (final match in pattern.allMatches(html)) {
    addText(html.substring(index, match.start));
    final tag = match.group(0)!;
    final name = RegExp(r'^</?\s*([a-zA-Z0-9]+)')
        .firstMatch(tag)
        ?.group(1)
        ?.toLowerCase();
    final closing = tag.startsWith('</');

    if (name == 'br') {
      addText('\n');
    } else if (name == 'strong' || name == 'b') {
      if (closing) {
        pop();
      } else {
        push((styles.last).copyWith(fontWeight: FontWeight.w700));
      }
    } else if (name == 'em' || name == 'i') {
      if (closing) {
        pop();
      } else {
        push((styles.last).copyWith(fontStyle: FontStyle.italic));
      }
    } else if (name == 'u') {
      if (closing) {
        pop();
      } else {
        push(
          (styles.last).copyWith(decoration: TextDecoration.underline),
        );
      }
    } else if (name == 's' || name == 'del' || name == 'strike') {
      if (closing) {
        pop();
      } else {
        push(
          (styles.last).copyWith(decoration: TextDecoration.lineThrough),
        );
      }
    } else if (name == 'code') {
      if (closing) {
        pop();
      } else {
        push(
          (styles.last).copyWith(
            fontFamily: 'monospace',
            backgroundColor: const Color(0x14000000),
          ),
        );
      }
    } else if (name == 'a') {
      if (closing) {
        pop();
      } else {
        push(
          (styles.last).copyWith(
            color: linkColor,
            decoration: TextDecoration.underline,
          ),
        );
      }
    }
    index = match.end;
  }
  addText(html.substring(index));

  return spans;
}
