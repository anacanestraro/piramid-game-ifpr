import 'course.dart';

// Pessoa que pode ser avaliada no ranking.
// Não guarda notas: as avaliações são uma entidade separada,
// porque cada usuário avalia a mesma pessoa de forma independente.
class Person {
  final String id;
  final String name;
  final String nickname;
  final Course course;
  final int classYear;
  final DateTime birthDate;

  // Uid do usuário que cadastrou esta pessoa.
  final String createdBy;

  // Uid da conta que "é" esta pessoa (null = pessoa sem conta).
  // Usado para impedir a autoavaliação.
  final String? linkedUserUid;

  const Person({
    required this.id,
    required this.name,
    required this.nickname,
    required this.course,
    required this.classYear,
    required this.birthDate,
    required this.createdBy,
    this.linkedUserUid,
  });

  bool isLinkedTo(String uid) => linkedUserUid == uid;

  bool wasCreatedBy(String uid) => createdBy == uid;

  Person copyWith({
    String? id,
    String? name,
    String? nickname,
    Course? course,
    int? classYear,
    DateTime? birthDate,
    String? createdBy,
    String? linkedUserUid,
    bool clearLinkedUser = false,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      course: course ?? this.course,
      classYear: classYear ?? this.classYear,
      birthDate: birthDate ?? this.birthDate,
      createdBy: createdBy ?? this.createdBy,
      // Com "??" não daria para voltar o vínculo para null,
      // por isso o parâmetro clearLinkedUser.
      linkedUserUid:
          clearLinkedUser ? null : (linkedUserUid ?? this.linkedUserUid),
    );
  }
}