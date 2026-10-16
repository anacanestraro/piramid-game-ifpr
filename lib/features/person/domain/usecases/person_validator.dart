import '../../../../core/result/result.dart';
import '../entities/person.dart';

// Regras de preenchimento do cadastro de pessoa.
// Retorna null se válido, ou uma Failure descrevendo o problema.
class PersonValidator {
  // Seção 8.2 da especificação.
  static const minClassYear = 1998;
  static const maxClassYear = 2026;

  Failure? validate(Person person) {
    if (person.name.trim().isEmpty) {
      return const Failure('O nome é obrigatório.');
    }

    if (person.nickname.trim().isEmpty) {
      return const Failure('O apelido é obrigatório.');
    }

    if (person.classYear < minClassYear || person.classYear > maxClassYear) {
      return const Failure(
        'A turma/ano deve estar entre $minClassYear e $maxClassYear.',
      );
    }

    if (person.birthDate.isAfter(DateTime.now())) {
      return const Failure('A data de nascimento não pode estar no futuro.');
    }

    return null;
  }
}