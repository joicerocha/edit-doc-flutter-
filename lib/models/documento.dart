import 'package:flutter/material.dart';

/// Modelo de dados: um documento do editor.
class Documento {
  final String id;
  String titulo;
  String conteudo;

  /// 'pdf', 'txt', 'md' ou 'novo' (guardado como texto no JSON).
  final String tipoIcone;

  Documento({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.tipoIcone,
  });

  IconData get icone {
    switch (tipoIcone) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
        return Icons.description;
      case 'md':
        return Icons.sticky_note_2;
      default:
        return Icons.note_add;
    }
  }

  // Objeto -> Map (depois o jsonEncode transforma em texto)
  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'tipoIcone': tipoIcone,
      };

  // Map (vindo do jsonDecode) -> objeto
  factory Documento.fromMap(Map<String, dynamic> mapa) => Documento(
        id: mapa['id'] as String,
        titulo: mapa['titulo'] as String,
        conteudo: mapa['conteudo'] as String,
        tipoIcone: mapa['tipoIcone'] as String,
      );
}
