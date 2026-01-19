class HomeHealthRecovery {
  final double? oxygenLevel;
  final double? pulseRate;
  final double? carbonMonoxideLevel;

  HomeHealthRecovery({
    this.oxygenLevel,
    this.pulseRate,
    this.carbonMonoxideLevel,
  });

  factory HomeHealthRecovery.fromJson(Map<String, dynamic> json) {
    print('🏥 [HomeHealthRecovery] Parsing JSON: $json');

    // Parse nested objects - API returns object with {id, name, value, ...}
    double? parseValue(dynamic data) {
      if (data == null) return null;

      // If it's already a number, return it
      if (data is num) {
        print('📊 [HomeHealthRecovery] Direct number value: $data');
        return data.toDouble();
      }

      // If it's an object with 'value' field, extract the value
      if (data is Map<String, dynamic> && data.containsKey('value')) {
        final value = data['value'];
        print('📊 [HomeHealthRecovery] Extracted value from object: $value');
        return value != null ? (value as num).toDouble() : null;
      }

      print('⚠️ [HomeHealthRecovery] Unable to parse value from: $data');
      return null;
    }

    return HomeHealthRecovery(
      oxygenLevel: parseValue(json['oxygenLevel']),
      pulseRate: parseValue(json['pulseRate']),
      carbonMonoxideLevel: parseValue(json['carbonMonoxideLevel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oxygenLevel': oxygenLevel,
      'pulseRate': pulseRate,
      'carbonMonoxideLevel': carbonMonoxideLevel,
    };
  }

  bool get hasData {
    return oxygenLevel != null ||
        pulseRate != null ||
        carbonMonoxideLevel != null;
  }
}
