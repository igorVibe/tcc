class Telemetria {
  final int id;
  final String rover;
  final double? umidadeSolo;
  final double? umidadeAr;
  final double? temperaturaAr;
  final double? qualidadeAr;
  final double? latitude;
  final double? longitude;
  final int? sinalLoraRssi;
  final DateTime? dataHora;

  Telemetria({
    required this.id,
    required this.rover,
    this.umidadeSolo,
    this.umidadeAr,
    this.temperaturaAr,
    this.qualidadeAr,
    this.latitude,
    this.longitude,
    this.sinalLoraRssi,
    this.dataHora,
  });

  factory Telemetria.fromJson(Map<String, dynamic> json) {
    return Telemetria(
      id: json['id'] ?? 0,
      rover: json['rover'].toString(),
      umidadeSolo: _toDouble(json['umidade_solo']),
      umidadeAr: _toDouble(json['umidade_ar']),
      temperaturaAr: _toDouble(json['temperatura_ar']),
      qualidadeAr: _toDouble(json['qualidade_ar']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      sinalLoraRssi: json['sinal_lora_rssi'],
      dataHora: json['data_hora'] != null
          ? DateTime.tryParse(json['data_hora'])
          : null,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}