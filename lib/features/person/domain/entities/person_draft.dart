import 'course.dart';

// Dados que o usuário preenche no formulário de pessoa.
// Não contém id, createdBy nem linkedUserUid: esses são definidos
// pelos use cases a partir do usuário logado, nunca pela tela.
class PersonDraft {
  final String name;
  final String nickname;
  final Course course;
  final int classYear;
  final DateTime birthDate;

  // "Esta pessoa sou eu": vincula a pessoa à conta logada.
  final bool isMe;

  const PersonDraft({
    required this.name,
    required this.nickname,
    required this.course,
    required this.classYear,
    required this.birthDate,
    this.isMe = false,
  });
}