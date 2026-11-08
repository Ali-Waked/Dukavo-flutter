import 'package:dukavo_mobile/features/marketing/presentation/public_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseContentBlocks', () {
    test('joins consecutive paragraph lines and splits on blank lines', () {
      final blocks = parseContentBlocks(
        'Dukavo is built for merchants.\n'
        'It keeps the work in order.\n'
        '\n'
        'A second paragraph.',
      );

      expect(blocks, hasLength(2));
      expect(blocks.first.kind, ContentBlockKind.paragraph);
      expect(
        blocks.first.text,
        'Dukavo is built for merchants. It keeps the work in order.',
      );
      expect(blocks.last.text, 'A second paragraph.');
    });

    test('parses unordered, ordered and note blocks', () {
      final blocks = parseContentBlocks(
        '- Products\n'
        '* Inventory\n'
        '\n'
        '1. First\n'
        '2) Second\n'
        '\n'
        '> Keep receipts.\n'
        '> Send them with the order.',
      );

      expect(blocks, hasLength(3));
      expect(blocks[0].kind, ContentBlockKind.unorderedList);
      expect(blocks[0].items, ['Products', 'Inventory']);
      expect(blocks[1].kind, ContentBlockKind.orderedList);
      expect(blocks[1].items, ['First', 'Second']);
      expect(blocks[2].kind, ContentBlockKind.note);
      expect(blocks[2].text, 'Keep receipts. Send them with the order.');
    });

    test('handles windows newlines and empty bodies', () {
      expect(parseContentBlocks(''), isEmpty);
      expect(parseContentBlocks('   \n\n '), isEmpty);
      expect(
        parseContentBlocks('One\r\nTwo').single.text,
        'One Two',
      );
    });
  });

  group('parseLabeledItems', () {
    test('splits on the first colon and keeps unlabeled lines', () {
      final items = parseLabeledItems(
        'Add products: Name, price and stock.\n'
        'Invite the team\n'
        'Connect WhatsApp: One inbox.',
      );

      expect(items, hasLength(3));
      expect(items[0].title, 'Add products');
      expect(items[0].description, 'Name, price and stock.');
      expect(items[1].title, 'Invite the team');
      expect(items[1].description, '');
      expect(items[2].title, 'Connect WhatsApp');
      expect(items[2].description, 'One inbox.');
    });

    test('ignores blank lines', () {
      expect(parseLabeledItems('\n\nOne: two\n\n'), hasLength(1));
    });
  });

  group('parseHtmlBlocks', () {
    test('splits sanitized HTML into headings, paragraphs and lists', () {
      final blocks = parseHtmlBlocks(
        '<h2>Product news</h2>'
        '<p>Hello <strong>merchant</strong>.</p>'
        '<ul><li>One</li><li>Two</li></ul>',
      );

      expect(
        blocks.map((block) => block.kind),
        [
          HtmlBlockKind.heading,
          HtmlBlockKind.paragraph,
          HtmlBlockKind.listItem,
          HtmlBlockKind.listItem,
        ],
      );
      expect(blocks[0].html, 'Product news');
      expect(blocks[1].html, contains('<strong>merchant</strong>'));
    });

    test('drops scripts, styles and comments', () {
      final blocks = parseHtmlBlocks(
        '<script>alert(1)</script>'
        '<style>p { color: red }</style>'
        '<!-- hidden -->'
        '<p>Visible</p>',
      );

      expect(blocks, hasLength(1));
      expect(blocks.single.html, 'Visible');
    });

    test('extracts images, captions and dividers', () {
      final blocks = parseHtmlBlocks(
        '<figure><img src="https://cdn.example/cover.jpg" alt="Cover">'
        '<figcaption>A &amp; B</figcaption></figure><hr>',
      );

      expect(blocks[0].kind, HtmlBlockKind.image);
      expect(blocks[0].src, 'https://cdn.example/cover.jpg');
      expect(blocks[0].alt, 'Cover');
      expect(blocks[1].kind, HtmlBlockKind.caption);
      expect(blocks[1].html, contains('A &amp; B'));
      expect(blocks[2].kind, HtmlBlockKind.divider);
    });
  });

  group('decodeHtmlEntities', () {
    test('decodes named and numeric entities', () {
      expect(
        decodeHtmlEntities('A &amp; B &lt;tag&gt; &quot;x&quot; &#39;y&#39;'),
        'A & B <tag> "x" \'y\'',
      );
      expect(decodeHtmlEntities('&mdash; &hellip; &#65;'), '— … A');
    });
  });

  group('parseHtmlInline', () {
    test('applies inline styles and decodes text', () {
      final spans = parseHtmlInline(
        'A <strong>bold</strong> and <a href="#">linked</a> &amp; done',
        const TextStyle(),
        linkColor: const Color(0xFF0F766E),
      );

      final texts = spans.whereType<TextSpan>().toList();
      expect(
        texts.map((span) => span.text ?? '').join(),
        'A bold and linked & done',
      );
      expect(
        texts.firstWhere((span) => span.text == 'bold').style?.fontWeight,
        FontWeight.w700,
      );
      expect(
        texts.firstWhere((span) => span.text == 'linked').style?.color,
        const Color(0xFF0F766E),
      );
    });
  });
}
