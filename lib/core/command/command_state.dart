import '../result/result.dart';

enum CommandStatus { idle, running, success, error }

// Estado imutável de um Command, exposto pra UI via Signal
class CommandState {
  final CommandStatus status;
  final Object? error;

  const CommandState({this.status = CommandStatus.idle, this.error});

  bool get isRunning => status == CommandStatus.running;
  bool get isError => status == CommandStatus.error;
  bool get isSuccess => status == CommandStatus.success;

  // Mensagem pronta para exibir ao usuário.
  String get errorMessage {
    final currentError = error;
    if (currentError is Failure) return currentError.message;
    return 'Ocorreu um erro inesperado.';
  }

  CommandState copyWith({CommandStatus? status, Object? error}) {
    return CommandState(
      status: status ?? this.status,
      error: error,
    );
  }
}