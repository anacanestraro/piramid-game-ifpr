// Cursos disponíveis no campus (seção 8.1 da especificação).
enum Course { info, mec, mamb, prod, tads, tga }

extension CourseLabel on Course {
  String get label {
    switch (this) {
      case Course.info:
        return 'INFO';
      case Course.mec:
        return 'MEC';
      case Course.mamb:
        return 'MAMB';
      case Course.prod:
        return 'PROD';
      case Course.tads:
        return 'TADS';
      case Course.tga:
        return 'TGA';
    }
  }
}