class Rover {
  final String idRover;
  final String nome;
  final double bateria;
  final DateTime? ultimaConexao;

  Rover({
    required this.idRover,
    required this.nome,
    required this.bateria,
    this.ultimaConexao,
  });

  factory Rover.fromJson(Map<String, dynamic> json) {
    return Rover(
      idRover: json['id_rover'] ?? '',
      nome: json['nome'] ?? '',
      bateria: (json['bateria'] ?? 0).toDouble(),
      ultimaConexao: json['ultima_conexao'] != null
          ? DateTime.tryParse(json['ultima_conexao'])
          : null,
    );
  }
}