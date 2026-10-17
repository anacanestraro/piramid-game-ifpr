// Os 15 critérios de popularidade (seção 10 da especificação).
enum CriteriaType {
  resenha,
  presencaVip,
  aura,
  modoParceiro,
  carismaNatural,
  humorDeMilhoes,
  energiaDeGrupo,
  criatividadeCaotica,
  modoAtleta,
  talentoDePalco,
  dripEscolar,
  coracaoDeDorama,
  queridinhoDosProfessores,
  cerebroTurbo,
  caosControlado,
}

// Nome e descrição de cada critério, para a UI não ter strings soltas.
extension CriteriaTypeInfo on CriteriaType {
  String get label {
    switch (this) {
      case CriteriaType.resenha:
        return 'Resenha';
      case CriteriaType.presencaVip:
        return 'Presença VIP';
      case CriteriaType.aura:
        return 'Aura';
      case CriteriaType.modoParceiro:
        return 'Modo Parceiro';
      case CriteriaType.carismaNatural:
        return 'Carisma Natural';
      case CriteriaType.humorDeMilhoes:
        return 'Humor de Milhões';
      case CriteriaType.energiaDeGrupo:
        return 'Energia de Grupo';
      case CriteriaType.criatividadeCaotica:
        return 'Criatividade Caótica';
      case CriteriaType.modoAtleta:
        return 'Modo Atleta';
      case CriteriaType.talentoDePalco:
        return 'Talento de Palco';
      case CriteriaType.dripEscolar:
        return 'Drip Escolar';
      case CriteriaType.coracaoDeDorama:
        return 'Coração de Dorama';
      case CriteriaType.queridinhoDosProfessores:
        return 'Queridinho dos Professores';
      case CriteriaType.cerebroTurbo:
        return 'Cérebro Turbo';
      case CriteriaType.caosControlado:
        return 'Caos Controlado';
    }
  }

  String get description {
    switch (this) {
      case CriteriaType.resenha:
        return 'Mede o quanto a pessoa anima a turma, puxa conversa e deixa o ambiente mais descontraído.';
      case CriteriaType.presencaVip:
        return 'Avalia o quanto a pessoa é lembrada, percebida ou reconhecida pelos colegas no dia a dia.';
      case CriteriaType.aura:
        return 'Representa a energia geral: presença, estilo, jeito de ser e impacto que causa no ambiente.';
      case CriteriaType.modoParceiro:
        return 'Mede o quanto a pessoa ajuda os colegas, colabora nas atividades e demonstra parceria.';
      case CriteriaType.carismaNatural:
        return 'Avalia a facilidade para socializar, conversar e criar boas relações.';
      case CriteriaType.humorDeMilhoes:
        return 'Representa o quanto a pessoa contribui com bom humor e momentos divertidos.';
      case CriteriaType.energiaDeGrupo:
        return 'Mede a participação em trabalhos, eventos, jogos e atividades coletivas.';
      case CriteriaType.criatividadeCaotica:
        return 'Avalia a capacidade de ter ideias diferentes, soluções inesperadas e comentários geniais.';
      case CriteriaType.modoAtleta:
        return 'Representa a aptidão esportiva, a disposição física e o espírito competitivo saudável.';
      case CriteriaType.talentoDePalco:
        return 'Mede a aptidão artística: música, canto, instrumentos, dança ou presença em apresentações.';
      case CriteriaType.dripEscolar:
        return 'Avalia o estilo pessoal: roupas, tênis, cabelo, acessórios e presença visual.';
      case CriteriaType.coracaoDeDorama:
        return 'Representa o carisma afetivo e a gentileza, sem expor relacionamentos reais.';
      case CriteriaType.queridinhoDosProfessores:
        return 'Mede a boa relação com os professores: respeito, participação e responsabilidade.';
      case CriteriaType.cerebroTurbo:
        return 'Avalia o desempenho nos estudos e a facilidade para aprender e resolver problemas.';
      case CriteriaType.caosControlado:
        return 'Mede o quanto a pessoa é zoeira ou imprevisível, sem passar dos limites do respeito.';
    }
  }
}

// Limites do Star Rating (seção 10 e 16 da especificação).
class CriteriaScoreLimits {
  CriteriaScoreLimits._();

  static const int min = 1;
  static const int max = 5;

  // 15 critérios x 5 estrelas.
  static int get maxTotal => CriteriaType.values.length * max;
}