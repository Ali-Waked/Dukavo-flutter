/// Omnichannel integrations.
///
/// A channel is a declared capability set (what the provider can do); a
/// connection is this workspace's actual account on it. Credential *values*
/// never appear here — the API returns field names and whether each is stored.
library;

class ChannelCapabilities {
  const ChannelCapabilities({
    required this.text,
    required this.image,
    required this.document,
    required this.audio,
    required this.voice,
    required this.video,
    required this.template,
    required this.deliveryStatus,
    required this.readStatus,
    required this.mediaDownload,
    required this.typing,
  });

  factory ChannelCapabilities.fromJson(Map<String, dynamic> json) {
    return ChannelCapabilities(
      text: json['text'] == true,
      image: json['image'] == true,
      document: json['document'] == true,
      audio: json['audio'] == true,
      voice: json['voice'] == true,
      video: json['video'] == true,
      template: json['template'] == true,
      deliveryStatus: json['delivery_status'] == true,
      readStatus: json['read_status'] == true,
      mediaDownload: json['media_download'] == true,
      typing: json['typing'] == true,
    );
  }

  final bool text;
  final bool image;
  final bool document;
  final bool audio;
  final bool voice;
  final bool video;
  final bool template;
  final bool deliveryStatus;
  final bool readStatus;
  final bool mediaDownload;
  final bool typing;

  /// The capability keys that are on, in display order.
  List<String> get enabled => <String>[
        if (text) 'text',
        if (image) 'image',
        if (document) 'document',
        if (audio) 'audio',
        if (voice) 'voice',
        if (video) 'video',
        if (template) 'template',
        if (deliveryStatus) 'delivery_status',
        if (readStatus) 'read_status',
        if (mediaDownload) 'media_download',
        if (typing) 'typing',
      ];
}

class CredentialField {
  const CredentialField({
    required this.key,
    required this.label,
    required this.secret,
    required this.required,
    required this.help,
    required this.configured,
  });

  factory CredentialField.fromJson(Map<String, dynamic> json) {
    return CredentialField(
      key: '${json['key'] ?? ''}',
      label: '${json['label'] ?? ''}',
      secret: json['secret'] == true,
      required: json['required'] == true,
      help: '${json['help'] ?? ''}',
      configured: json['configured'] == true,
    );
  }

  final String key;
  final String label;
  final bool secret;
  final bool required;
  final String help;

  /// Whether the server already holds a value. The value itself never travels.
  final bool configured;
}

class ChannelConnection {
  const ChannelConnection({
    required this.id,
    required this.channel,
    required this.storeId,
    required this.name,
    required this.status,
    required this.health,
    required this.externalAccountId,
    required this.errorMessage,
    required this.webhookUrl,
    required this.lastHealthCheckAt,
    required this.storeName,
    required this.credentialFields,
  });

  factory ChannelConnection.fromJson(Map<String, dynamic> json) {
    final store = json['store'];
    final fields = json['credential_fields'];

    return ChannelConnection(
      id: json['id'] is int ? json['id'] as int : 0,
      channel: '${json['channel'] ?? ''}',
      storeId: json['store_id'] is int ? json['store_id'] as int : null,
      name: '${json['name'] ?? ''}',
      status: '${json['status'] ?? 'pending'}',
      health: '${json['health'] ?? 'unknown'}',
      externalAccountId: json['external_account_id'] as String?,
      errorMessage: json['error_message'] as String?,
      webhookUrl: '${json['webhook_url'] ?? ''}',
      lastHealthCheckAt: json['last_health_check_at'] as String?,
      storeName: store is Map ? '${store['name'] ?? ''}' : null,
      credentialFields: fields is List
          ? fields
              .whereType<Map>()
              .map((entry) =>
                  CredentialField.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <CredentialField>[],
    );
  }

  final int id;
  final String channel;
  final int? storeId;
  final String name;
  final String status;
  final String health;
  final String? externalAccountId;
  final String? errorMessage;
  final String webhookUrl;
  final String? lastHealthCheckAt;
  final String? storeName;
  final List<CredentialField> credentialFields;
}

class ChannelDefinition {
  const ChannelDefinition({
    required this.key,
    required this.name,
    required this.provider,
    required this.availability,
    required this.capabilities,
    required this.credentialFields,
    required this.notes,
    required this.connections,
  });

  factory ChannelDefinition.fromJson(Map<String, dynamic> json) {
    final rawCapabilities = json['capabilities'];
    final rawFields = json['credential_fields'];
    final rawConnections = json['connections'];

    return ChannelDefinition(
      key: '${json['key'] ?? ''}',
      name: '${json['name'] ?? ''}',
      provider: '${json['provider'] ?? ''}',
      availability: '${json['availability'] ?? 'available'}',
      capabilities: ChannelCapabilities.fromJson(
        rawCapabilities is Map
            ? Map<String, dynamic>.from(rawCapabilities)
            : const <String, dynamic>{},
      ),
      credentialFields: rawFields is List
          ? rawFields
              .whereType<Map>()
              .map((entry) =>
                  CredentialField.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <CredentialField>[],
      notes: '${json['notes'] ?? ''}',
      connections: rawConnections is List
          ? rawConnections
              .whereType<Map>()
              .map((entry) =>
                  ChannelConnection.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <ChannelConnection>[],
    );
  }

  final String key;
  final String name;
  final String provider;
  final String availability;
  final ChannelCapabilities capabilities;
  final List<CredentialField> credentialFields;
  final String notes;
  final List<ChannelConnection> connections;

  bool get awaitsProviderAccess => availability == 'awaiting_provider_access';
  bool get awaitsConfiguration => availability == 'awaiting_configuration';
}

/// What the connect/edit form submits.
class IntegrationDraft {
  const IntegrationDraft({
    required this.name,
    required this.storeId,
    required this.credentials,
  });

  final String name;
  final int? storeId;
  final Map<String, String> credentials;

  Map<String, dynamic> toJson({String? channel}) {
    return <String, dynamic>{
      if (channel != null) 'channel': channel,
      'name': name,
      'store_id': storeId,
      'credentials': credentials,
    };
  }
}

abstract class IntegrationsRepository {
  Future<List<ChannelDefinition>> getChannels();

  Future<void> connect(String channel, IntegrationDraft draft);

  Future<void> update(int id, IntegrationDraft draft);

  Future<void> disconnect(int id);

  Future<void> test(int id);

  Future<void> reconnect(int id);
}
