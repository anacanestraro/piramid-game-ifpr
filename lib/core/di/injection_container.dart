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

// --- Student (será removido no passo 8) ---
import '../../features/student/data/services/student_local_service.dart';
import '../../features/student/data/services/student_shared_prefs_service.dart';
import '../../features/student/data/repositories/student_repository_impl.dart';
import '../../features/student/domain/repositories/student_repository.dart';
import '../../features/student/domain/usecases/create_student_usecase.dart';
import '../../features/student/domain/usecases/update_student_usecase.dart';
import '../../features/student/domain/usecases/delete_student_usecase.dart';
import '../../features/student/domain/usecases/get_all_students_usecase.dart';
import '../../features/student/domain/usecases/get_student_by_id_usecase.dart';
import '../../features/student/domain/usecases/calculate_ranking_usecase.dart';
import '../../features/student/facade/student_usecases_facade.dart';
import '../../features/student/presentation/viewmodels/student_form_viewmodel.dart';
import '../../features/student/presentation/viewmodels/ranking_viewmodel.dart';
import '../../features/student/presentation/viewmodels/student_detail_viewmodel.dart';

// --- Theme ---
import '../../features/theme_settings/data/services/theme_local_service.dart';
import '../../features/theme_settings/data/services/theme_shared_prefs_service.dart';
import '../../features/theme_settings/data/repositories/theme_repository_impl.dart';
import '../../features/theme_settings/domain/repositories/theme_repository.dart';
import '../../features/theme_settings/domain/usecases/get_theme_mode_usecase.dart';
import '../../features/theme_settings/domain/usecases/toggle_theme_usecase.dart';
import '../../features/theme_settings/facade/theme_usecases_facade.dart';
import '../../features/theme_settings/presentation/viewmodels/theme_viewmodel.dart';

class InjectionContainer {
  InjectionContainer._();

  static final InjectionContainer instance = InjectionContainer._();

  late final LocalStorageHelper _storageHelper;

  // --- Auth ---
  late final AuthRepository _authRepository;
  late final RequireAuthenticatedUser _requireUser;
  late final AuthUseCasesFacade authFacade;

  // --- Person / Evaluation ---
  late final PersonRepository _personRepository;
  late final PersonUseCasesFacade personFacade;
  late final EvaluationRepository _evaluationRepository;
  late final EvaluationUseCasesFacade evaluationFacade;

  // --- Student ---
  late final StudentLocalService _studentLocalService;
  late final StudentRepository _studentRepository;
  late final StudentUseCasesFacade studentFacade;

  // --- Theme ---
  late final ThemeLocalService _themeLocalService;
  late final ThemeRepository _themeRepository;
  late final ThemeUseCasesFacade themeFacade;

  // --- ViewModels ---
  late final AuthViewModel authViewModel;
  late final PeopleListViewModel peopleListViewModel;
  late final PersonFormViewModel personFormViewModel;
  late final PersonDetailViewModel personDetailViewModel;
  late final StudentFormViewModel studentFormViewModel;
  late final RankingViewModel rankingViewModel;
  late final StudentDetailViewModel studentDetailViewModel;
  late final ThemeViewModel themeViewModel;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await SharedPreferences.getInstance();

    _storageHelper = LocalStorageHelper();

    // Repositories primeiro: os use cases de uma feature podem
    // depender do repository de outra (ex.: remover pessoa).
    _personRepository = PersonRepositoryImpl(PersonFirestoreService());
    _evaluationRepository =
        EvaluationRepositoryImpl(EvaluationFirestoreService());

    _initAuth();
    _initEvaluation();
    _initPerson();
    _initStudent();
    _initTheme();
    _initViewModels();

    _initialized = true;
  }

  void _initAuth() {
    _authRepository = AuthRepositoryImpl(
      FirebaseAuthService(),
      FirebaseGoogleAuthService(),
      UserFirestoreService(),
    );

    _requireUser = RequireAuthenticatedUser(_authRepository);

    authFacade = AuthUseCasesFacade(
      signUp: SignUpUseCase(_authRepository),
      signIn: SignInUseCase(_authRepository),
      signInWithGoogle: SignInWithGoogleUseCase(_authRepository),
      getCurrentUser: GetCurrentUserUseCase(_authRepository),
      signOut: SignOutUseCase(_authRepository),
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

  void _initStudent() {
    _studentLocalService = StudentSharedPrefsService(_storageHelper);
    _studentRepository = StudentRepositoryImpl(_studentLocalService);
    studentFacade = StudentUseCasesFacade(
      createStudent: CreateStudentUseCase(_studentRepository),
      updateStudent: UpdateStudentUseCase(_studentRepository),
      deleteStudent: DeleteStudentUseCase(_studentRepository),
      getAllStudents: GetAllStudentsUseCase(_studentRepository),
      getStudentById: GetStudentByIdUseCase(_studentRepository),
      calculateRanking: CalculateRankingUseCase(_studentRepository),
    );
  }

  void _initTheme() {
    _themeLocalService = ThemeSharedPrefsService(_storageHelper);
    _themeRepository = ThemeRepositoryImpl(_themeLocalService);
    themeFacade = ThemeUseCasesFacade(
      getThemeMode: GetThemeModeUseCase(_themeRepository),
      toggleTheme: ToggleThemeUseCase(_themeRepository),
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

    studentFormViewModel = StudentFormViewModel(studentFacade);
    rankingViewModel = RankingViewModel(studentFacade);
    studentDetailViewModel = StudentDetailViewModel(studentFacade);
    themeViewModel = ThemeViewModel(themeFacade);
  }
}