import 'package:cloud_firestore/cloud_firestore.dart';

class Resumo {
  final String userId;
  final Timestamp data;
  final String resumo;

  Resumo({required this.userId, required this.data, required this.resumo});

  // Construtor para criar a partir de um mapa (para recuperar do Firestore)
  factory Resumo.fromJson(Map<String, dynamic> json) => Resumo(
        userId: json['userId'],
        data: json['data'],
        resumo: json['resumo'],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'data': data,
        'resumo': resumo,
      };
}
