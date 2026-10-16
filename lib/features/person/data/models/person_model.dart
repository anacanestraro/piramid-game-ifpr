import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/extensions/enum_extensions.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/person.dart';

class PersonModelParseException implements Exception {
  final String message;
  const PersonModelParseException(this.message);

  @override
  String toString() => 'PersonModelParseException: $message';
}

// Envolve a entidade Person, adicionando conversão de/para Firestore.
// O domínio (Person) nunca conhece Firestore - só este Model conhece.
class PersonModel extends Person {
  const PersonModel({
    required super.id,
    required super.name,
    required super.nickname,
    required super.course,
    required super.classYear,
    required super.birthDate,
    required super.createdBy,
    super.linkedUserUid,
  });

  factory PersonModel.fromEntity(Person person) {
    return PersonModel(
      id: person.id,
      name: person.name,
      nickname: person.nickname,
      course: person.course,
      classYear: person.classYear,
      birthDate: person.birthDate,
      createdBy: person.createdBy,
      linkedUserUid: person.linkedUserUid,
    );
  }

  // O id vem do documento, não de dentro dos dados.
  factory PersonModel.fromFirestore(String id, Map<String, dynamic> data) {
    try {
      final courseRaw = data['course'] as String;
      final course = Course.values.byNameOrNull(courseRaw);
      if (course == null) {
        throw PersonModelParseException('Curso desconhecido: "$courseRaw"');
      }

      return PersonModel(
        id: id,
        name: data['name'] as String,
        nickname: data['nickname'] as String,
        course: course,
        classYear: (data['classYear'] as num).toInt(),
        // O Firestore guarda datas como Timestamp.
        birthDate: (data['birthDate'] as Timestamp).toDate(),
        createdBy: data['createdBy'] as String,
        linkedUserUid: data['linkedUserUid'] as String?,
      );
    } on PersonModelParseException {
      rethrow;
    } catch (e) {
      throw PersonModelParseException(
        'Falha ao converter a pessoa "$id": $e',
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nickname': nickname,
      'course': course.name,
      'classYear': classYear,
      'birthDate': Timestamp.fromDate(birthDate),
      'createdBy': createdBy,
      'linkedUserUid': linkedUserUid,
    };
  }
}