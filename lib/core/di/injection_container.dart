import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage_helper.dart';

// --- Auth ---
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/firebase_auth_service.dart';
import '../../features/auth/data/services/firebase_google_auth_service.dart';
import '../../features/auth/data/services/user_firestore_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/facade/auth_usecases_facade.dart';

// --- Student ---
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
  late final AuthUseCasesFacade authFacade;

  // --- Student ---
  late final StudentLocalService _studentLocalService;
  late final StudentRepository _studentRepository;
  late final StudentUseCasesFacade studentFacade;

  // --- Theme ---
  late final ThemeLocalService _themeLocalService;
  late final ThemeRepository _themeRepository;
  late final ThemeUseCasesFacade themeFacade;

  // --- ViewModels ---
  late final StudentFormViewModel studentFormViewModel;
  late final RankingViewModel rankingViewModel;
  late final StudentDetailViewModel studentDetailViewModel;
  late final ThemeViewModel themeViewModel;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await SharedPreferences.getInstance();

    _storageHelper = LocalStorageHelper();

    _initAuth();
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

    authFacade = AuthUseCasesFacade(
      signUp: SignUpUseCase(_authRepository),
      signIn: SignInUseCase(_authRepository),
      signInWithGoogle: SignInWithGoogleUseCase(_authRepository),
      getCurrentUser: GetCurrentUserUseCase(_authRepository),
      signOut: SignOutUseCase(_authRepository),
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
    studentFormViewModel = StudentFormViewModel(studentFacade);
    rankingViewModel = RankingViewModel(studentFacade);
    studentDetailViewModel = StudentDetailViewModel(studentFacade);
    themeViewModel = ThemeViewModel(themeFacade);
  }
}