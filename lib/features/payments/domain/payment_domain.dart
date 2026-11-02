/// The payment methods a store may offer.
///
/// `available` is the server's answer, not a guess: cash on delivery is real,
/// and online payment stays unavailable until a provider is configured.
class PaymentMethodOption {
  const PaymentMethodOption({
    required this.code,
    required this.label,
    required this.description,
    required this.available,
    this.unavailableReason,
  });

  final String code;
  final String label;
  final String description;
  final bool available;
  final String? unavailableReason;
}

class PaymentSettings {
  const PaymentSettings({
    required this.codEnabled,
    required this.methods,
    this.codInstructions,
  });

  final bool codEnabled;
  final String? codInstructions;
  final List<PaymentMethodOption> methods;

  PaymentSettings copyWith({bool? codEnabled, String? codInstructions}) {
    return PaymentSettings(
      codEnabled: codEnabled ?? this.codEnabled,
      codInstructions: codInstructions ?? this.codInstructions,
      methods: methods,
    );
  }
}

class PaymentSettingsDraft {
  const PaymentSettingsDraft({
    required this.codEnabled,
    this.codInstructions,
  });

  final bool codEnabled;
  final String? codInstructions;
}

abstract class PaymentRepository {
  Future<PaymentSettings> get(int storeId);

  Future<PaymentSettings> update(int storeId, PaymentSettingsDraft draft);
}
