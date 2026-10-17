import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage_helper.dart';

// --- Auth ---
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/firebase_auth_service.dart';
import '../../features/auth/data/services/firebase_google_auth_service.dart';
import '../../features/auth/data/services/user_firestore_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/require_authenticated_user.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/facade/auth_usecases_facade.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

// --- Evaluation ---
import '../../features/evaluation/data/repositories/evaluation_repository_impl.dart';
import '../../features/evaluation/data/services/evaluation_firestore_service.dart';
import '../../features/evaluation/domain/repositories/evaluation_repository.dart';
import '../../features/evaluation/domain/usecases/check_self_evaluation_usecase.dart';
import '../../features/evaluation/domain/usecases/evaluation_preconditions.dart';
import '../../features/evaluation/domain/usecases/get_my_evaluation_usecase.dart';
import '../../features/evaluation/domain/usecases/get_my_evaluations_usecase.dart';
import '../../features/evaluation/domain/usecases/register_evaluation_usecase.dart';
import '../../features/evaluation/domain/usecases/update_evaluation_usecase.dart';
import '../../features/evaluation/facade/evaluation_usecases_facade.dart';
import '../../features/evaluation/presentation/viewmodels/evaluation_form_viewmodel.dart';

// --- Person ---
import '../../features/person/data/repositories/person_repository_impl.dart';
import '../../features/person/data/services/person_firestore_service.dart';
import '../../features/person/domain/repositories/person_repository.dart';
import '../../features/person/domain/usecases/create_person_usecase.dart';
import '../../features/person/domain/usecases/delete_person_usecase.dart';
import '../../features/person/domain/usecases/get_all_people_usecase.dart';
import '../../features/person/domain/usecases/get_person_by_id_usecase.dart';
import '../../features/person/domain/usecases/update_person_usecase.dart';
import '../../features/person/facade/person_usecases_facade.dart';
import '../../features/person/presentation/viewmodels/people_list_viewmodel.dart';
import '../../features/person/presentation/viewmodels/person_detail_viewmodel.dart';
import '../../features/person/presentation/viewmodels/person_form_viewmodel.dart';

// --- Ranking ---
import '../../features/ranking/domain/usecases/calculate_global_ranking_usecase.dart';
import '../../features/ranking/domain/usecases/calculate_personal_ranking_usecase.dart';
import '../../features/ranking/facade/ranking_usecases_facade.dart';
import '../../features/ranking/presentation/viewmodels/ranking_viewmodel.dart';

// --- Theme ---
import '../../features/theme_settings/data/services/theme_shared_prefs_service.dart';
import '../../features/theme_settings/data/repositories/theme_repository_impl.dart';
import '../../features/theme_settings/domain/usecases/get_theme_mode_usecase.dart';
import '../../features/theme_settings/domain/usecases/toggle_theme_usecase.dart';
import '../../features/theme_settings/facade/theme_usecases_facade.dart';
import '../../features/theme_settings/presentation/viewmodels/theme_viewmodel.dart';

class InjectionContainer {
  InjectionContainer._();

  static final InjectionContainer instance = InjectionContainer._();

  late final LocalStorageHelper _storageHelper;

  // --- Repositories compartilhados entre features ---
  late final AuthRepository _authRepository;
  late final PersonRepository _personRepository;
  late final EvaluationRepository _evaluationRepository;
  late final RequireAuthenticatedUser _requireUser;

  // --- Facades ---
  late final AuthUseCasesFacade authFacade;
  late final PersonUseCasesFacade personFacade;
  late final EvaluationUseCasesFacade evaluationFacade;
  late final RankingUseCasesFacade rankingFacade;
  late final ThemeUseCasesFacade themeFacade;

  // --- ViewModels ---
  late final AuthViewModel authViewModel;
  late final PeopleListViewModel peopleListViewModel;
  late final PersonFormViewModel personFormViewModel;
  late final PersonDetailViewModel personDetailViewModel;
  late final EvaluationFormViewModel evaluationFormViewModel;
  late final RankingViewModel rankingViewModel;
  late final ThemeViewModel themeViewModel;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await SharedPreferences.getInstance();

    _storageHelper = LocalStorageHelper();

    // Repositories primeiro: os use cases de uma feature podem
    // depender do repository de outra (ex.: remover pessoa, ranking).
    _authRepository = AuthRepositoryImpl(
      FirebaseAuthService(),
      FirebaseGoogleAuthService(),
      UserFirestoreService(),
    );
    _personRepository = PersonRepositoryImpl(PersonFirestoreService());
    _evaluationRepository =
        EvaluationRepositoryImpl(EvaluationFirestoreService());
    _requireUser = RequireAuthenticatedUser(_authRepository);

    _initAuth();
    _initPerson();
    _initEvaluation();
    _initRanking();
    _initTheme();
    _initViewModels();

    _initialized = true;
  }

  void _initAuth() {
    authFacade = AuthUseCasesFacade(
      signUp: SignUpUseCase(_authRepository),
      signIn: SignInUseCase(_authRepository),
      signInWithGoogle: SignInWithGoogleUseCase(_authRepository),
      getCurrentUser: GetCurrentUserUseCase(_authRepository),
      signOut: SignOutUseCase(_authRepository),
    );
  }

  void _initPerson() {
    personFacade = PersonUseCasesFacade(
      create: CreatePersonUseCase(_personRepository, _requireUser),
      update: UpdatePersonUseCase(_personRepository, _requireUser),
      delete: DeletePersonUseCase(
        _personRepository,
        _evaluationRepository,
        _requireUser,
      ),
      getAll: GetAllPeopleUseCase(_personRepository),
      getById: GetPersonByIdUseCase(_personRepository),
    );
  }

  void _initEvaluation() {
    final preconditions =
        EvaluationPreconditions(_requireUser, _personRepository);

    evaluationFacade = EvaluationUseCasesFacade(
      register: RegisterEvaluationUseCase(_evaluationRepository, preconditions),
      update: UpdateEvaluationUseCase(_evaluationRepository, preconditions),
      getMine: GetMyEvaluationUseCase(_evaluationRepository, _requireUser),
      getAllMine: GetMyEvaluationsUseCase(_evaluationRepository, _requireUser),
      checkSelf: CheckSelfEvaluationUseCase(_requireUser, _personRepository),
    );
  }

  void _initRanking() {
    rankingFacade = RankingUseCasesFacade(
      personal: CalculatePersonalRankingUseCase(
        _evaluationRepository,
        _personRepository,
        _requireUser,
      ),
      global: CalculateGlobalRankingUseCase(
        _evaluationRepository,
        _personRepository,
        _requireUser,
      ),
    );
  }

  void _initTheme() {
    final themeRepository = ThemeRepositoryImpl(
      ThemeSharedPrefsService(_storageHelper),
    );

    themeFacade = ThemeUseCasesFacade(
      getThemeMode: GetThemeModeUseCase(themeRepository),
      toggleTheme: ToggleThemeUseCase(themeRepository),
    );
  }

  void _initViewModels() {
    authViewModel = AuthViewModel(authFacade);

    peopleListViewModel = PeopleListViewModel(personFacade);
    personFormViewModel = PersonFormViewModel(personFacade);
    personDetailViewModel = PersonDetailViewModel(
      personFacade,
      authViewModel.currentUser,
    );
    evaluationFormViewModel = EvaluationFormViewModel(
      evaluationFacade,
      personFacade,
    );
    rankingViewModel = RankingViewModel(rankingFacade);
    themeViewModel = ThemeViewModel(themeFacade);
  }
}