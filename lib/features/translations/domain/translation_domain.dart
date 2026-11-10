/// AI translation review contracts.
///
/// These mirror `TranslationController::show()` and
/// `TranslationService::present()`. A row is a proposal until its status becomes
/// `approved`; `publishedText` is the copy the shopfront currently serves, so a
/// stale row can keep the last approved copy public while a newer draft waits for
/// review.
class TranslationSurface {
  const TranslationSurface._();

  static const tenant = 'tenant';
  static const platform = 'platform';
}

class TranslationFieldDefinition {
  const TranslationFieldDefinition({
    required this.key,
    required this.label,
    required this.format,
  });

  final String key;
  final String label;
  final String format;

  factory TranslationFieldDefinition.fromJson(Map<String, dynamic> json) {
    return TranslationFieldDefinition(
      key: _string(json['key']),
      label: _string(json['label'], fallback: _string(json['key'])),
      format: _string(json['format'], fallback: 'text'),
    );
  }

  bool get isHtml => format == 'html';
}

class TranslationEntitySummary {
  const TranslationEntitySummary({
    required this.key,
    required this.label,
    required this.id,
    required this.name,
    required this.tenantScoped,
  });

  final String key;
  final String label;
  final int id;
  final String name;
  final bool tenantScoped;

  factory TranslationEntitySummary.fromJson(Map<String, dynamic> json) {
    return TranslationEntitySummary(
      key: _string(json['key']),
      label: _string(json['label']),
      id: _int(json['id']),
      name: _string(json['name']),
      tenantScoped: json['tenant_scoped'] == true,
    );
  }
}

class TranslationSourceDetection {
  const TranslationSourceDetection({
    required this.locale,
    required this.confidence,
    required this.method,
  });

  final String? locale;
  final double confidence;
  final String method;

  factory TranslationSourceDetection.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TranslationSourceDetection(
        locale: null,
        confidence: 0,
        method: 'none',
      );
    }

    return TranslationSourceDetection(
      locale: _nullableString(json['locale']),
      confidence: _double(json['confidence']),
      method: _string(json['method'], fallback: 'none'),
    );
  }
}

class TranslationRow {
  const TranslationRow({
    required this.id,
    required this.locale,
    required this.field,
    required this.status,
    required this.statusLabel,
    required this.translatedText,
    required this.publishedText,
    required this.manuallyEdited,
    required this.origin,
    required this.sourceLocale,
    this.provider,
    this.model,
    this.generatedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    this.updatedAt,
  });

  final int? id;
  final String locale;
  final String field;
  final String status;
  final String statusLabel;
  final String? translatedText;
  final String? publishedText;
  final bool manuallyEdited;
  final String? origin;
  final String? sourceLocale;
  final String? provider;
  final String? model;
  final String? generatedAt;
  final String? reviewedAt;
  final int? reviewedBy;
  final String? rejectionReason;
  final String? updatedAt;

  factory TranslationRow.fromJson(Map<String, dynamic> json) {
    return TranslationRow(
      id: _nullableInt(json['id']),
      locale: _string(json['locale']),
      field: _string(json['field']),
      status: _string(json['status'], fallback: 'not_translated'),
      statusLabel:
          _string(json['status_label'], fallback: _string(json['status'])),
      translatedText: _nullableString(json['translated_text']),
      publishedText: _nullableString(json['published_text']),
      manuallyEdited: json['manually_edited'] == true,
      origin: _nullableString(json['origin']),
      sourceLocale: _nullableString(json['source_locale']),
      provider: _nullableString(json['provider']),
      model: _nullableString(json['model']),
      generatedAt: _nullableString(json['generated_at']),
      reviewedAt: _nullableString(json['reviewed_at']),
      reviewedBy: _nullableInt(json['reviewed_by']),
      rejectionReason: _nullableString(json['rejection_reason']),
      updatedAt: _nullableString(json['updated_at']),
    );
  }

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isGenerating => status == 'generating';
  bool get isStale => status == 'stale';
  bool get hasCopy => (translatedText ?? '').trim().isNotEmpty;

  /// Whether selecting this row for "approve selected" is meaningful.
  bool get canBeSelected => id != null && !isApproved && !isGenerating;
}

class TranslationOverview {
  const TranslationOverview({
    required this.entity,
    required this.sourceLocale,
    required this.sourceDetection,
    required this.sourceRequired,
    required this.enabledLocales,
    required this.targetLocales,
    required this.fields,
    required this.sources,
    required this.translations,
    required this.summary,
  });

  final TranslationEntitySummary entity;
  final String? sourceLocale;
  final TranslationSourceDetection sourceDetection;
  final bool sourceRequired;
  final List<String> enabledLocales;
  final List<String> targetLocales;
  final List<TranslationFieldDefinition> fields;
  final Map<String, String> sources;
  final Map<String, Map<String, TranslationRow>> translations;
  final Map<String, int> summary;

  factory TranslationOverview.fromJson(Map<String, dynamic> json) {
    final rawTranslations = json['translations'];

    return TranslationOverview(
      entity: TranslationEntitySummary.fromJson(_map(json['entity'])),
      sourceLocale: _nullableString(json['source_locale']),
      sourceDetection:
          TranslationSourceDetection.fromJson(_nullableMap(json['source_detection'])),
      sourceRequired: json['source_required'] == true,
      enabledLocales: _strings(json['enabled_locales']),
      targetLocales: _strings(json['target_locales']),
      fields: _list(json['fields'])
          .whereType<Map>()
          .map((entry) => TranslationFieldDefinition.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList(),
      sources: _stringMap(json['sources']),
      translations: rawTranslations is Map
          ? rawTranslations.map(
              (locale, fields) => MapEntry(
                '$locale',
                _translationFieldMap(fields),
              ),
            )
          : const {},
      summary: _intMap(json['summary']),
    );
  }

  TranslationFieldDefinition? field(String key) {
    for (final field in fields) {
      if (field.key == key) return field;
    }
    return null;
  }

  bool get isEmpty => translations.isEmpty;
}

class TranslationUsage {
  const TranslationUsage({
    required this.requests,
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.estimatedCost,
  });

  final int requests;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final double estimatedCost;

  static const empty = TranslationUsage(
    requests: 0,
    inputTokens: 0,
    outputTokens: 0,
    totalTokens: 0,
    estimatedCost: 0,
  );

  factory TranslationUsage.fromJson(Map<String, dynamic> json) {
    return TranslationUsage(
      requests: _int(json['requests']),
      inputTokens: _int(json['input_tokens']),
      outputTokens: _int(json['output_tokens']),
      totalTokens: _int(json['total_tokens']),
      estimatedCost: _double(json['estimated_cost']),
    );
  }
}

class GenerateTranslationsResult {
  const GenerateTranslationsResult({
    required this.sourceLocale,
    required this.sourceDetection,
    required this.translations,
  });

  final String sourceLocale;
  final TranslationSourceDetection sourceDetection;
  final Map<String, Map<String, TranslationRow>> translations;

  factory GenerateTranslationsResult.fromJson(Map<String, dynamic> json) {
    final rawTranslations = json['translations'];

    return GenerateTranslationsResult(
      sourceLocale: _string(json['source_locale']),
      sourceDetection:
          TranslationSourceDetection.fromJson(_nullableMap(json['source_detection'])),
      translations: rawTranslations is Map
          ? rawTranslations.map(
              (locale, fields) => MapEntry(
                '$locale',
                _translationFieldMap(fields),
              ),
            )
          : const {},
    );
  }
}

/// The languages Dukavo can publish, with the label an operator sees in a
/// picker. The server remains authoritative; this map only labels a code.
const translationLanguageLabels = <String, String>{
  'en': 'English',
  'ar': 'العربية',
  'fr': 'Français',
  'es': 'Español',
  'de': 'Deutsch',
  'it': 'Italiano',
  'pt': 'Português',
  'nl': 'Nederlands',
  'tr': 'Türkçe',
  'id': 'Bahasa Indonesia',
  'pl': 'Polski',
  'sv': 'Svenska',
  'da': 'Dansk',
  'ru': 'Русский',
  'uk': 'Українська',
  'fa': 'فارسی',
  'ur': 'اردو',
  'he': 'עברית',
  'hi': 'हिन्दी',
  'bn': 'বাংলা',
  'th': 'ไทย',
  'zh': '中文',
  'ja': '日本語',
  'ko': '한국어',
  'el': 'Ελληνικά',
};

String translationLanguageLabel(String code) {
  return translationLanguageLabels[code] ?? code.toUpperCase();
}

Map<String, TranslationRow> _translationFieldMap(Object? raw) {
  if (raw is! Map) return const {};
  final result = <String, TranslationRow>{};
  raw.forEach((field, row) {
    if (row is Map) {
      result['$field'] = TranslationRow.fromJson(
        Map<String, dynamic>.from(row),
      );
    }
  });
  return result;
}

Map<String, dynamic> _map(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}

Map<String, dynamic>? _nullableMap(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : null;
}

List<dynamic> _list(Object? value) => value is List ? value : const [];

List<String> _strings(Object? value) {
  return _list(value).map((entry) => '$entry').toList();
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return const {};
  final result = <String, String>{};
  value.forEach((key, entry) {
    if (entry is String) result['$key'] = entry;
  });
  return result;
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const {};
  final result = <String, int>{};
  value.forEach((key, entry) {
    result['$key'] = _int(entry);
  });
  return result;
}

String _string(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final text = '$value';
  return text.isEmpty ? null : text;
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
