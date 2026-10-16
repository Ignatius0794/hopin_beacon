// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sandbox/core/di/register_module.dart' as _i539;
import 'package:sandbox/core/presentation/bloc/app_locale_cubit.dart' as _i222;
import 'package:sandbox/core/presentation/bloc/app_theme_cubit.dart' as _i223;
import 'package:sandbox/core/routes/app_router.dart' as _i693;
import 'package:sandbox/core/theme/app_theme.dart' as _i599;
import 'package:sandbox/features/auth/data/datasources/auth_local_datasource.dart'
    as _i110;
import 'package:sandbox/features/auth/data/repositories/auth_repository_impl.dart'
    as _i111;
import 'package:sandbox/features/auth/domain/repositories/auth_repository.dart'
    as _i112;
import 'package:sandbox/features/auth/domain/usecases/login.dart' as _i113;
import 'package:sandbox/features/auth/presentation/bloc/auth_cubit.dart' as _i844;
import 'package:sandbox/features/menu/data/datasources/menu_local_datasource.dart'
    as _i120;
import 'package:sandbox/features/menu/data/repositories/menu_repository_impl.dart'
    as _i121;
import 'package:sandbox/features/menu/domain/repositories/menu_repository.dart'
    as _i122;
import 'package:sandbox/features/menu/domain/usecases/get_menu_entries.dart' as _i123;
import 'package:sandbox/features/menu/presentation/bloc/menu_cubit.dart' as _i124;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.factory<_i599.AppTheme>(() => _i599.AppTheme());
  gh.factory<_i110.AuthLocalDataSource>(() => _i110.AuthLocalDataSource());
  gh.factory<_i120.MenuLocalDataSource>(() => _i120.MenuLocalDataSource());
  gh.lazySingleton<_i112.AuthRepository>(
    () => _i111.AuthRepositoryImpl(gh<_i110.AuthLocalDataSource>()),
  );
  gh.lazySingleton<_i122.MenuRepository>(
    () => _i121.MenuRepositoryImpl(gh<_i120.MenuLocalDataSource>()),
  );
  gh.factory<_i113.Login>(() => _i113.Login(gh<_i112.AuthRepository>()));
  gh.factory<_i123.GetMenuEntries>(
    () => _i123.GetMenuEntries(gh<_i122.MenuRepository>()),
  );
  gh.lazySingleton<_i844.AuthCubit>(
    () => _i844.AuthCubit(gh<_i113.Login>()),
  );
  gh.singleton<_i693.AppRouter>(
    () => _i693.AppRouter(gh<_i844.AuthCubit>()),
  );
  gh.factory<_i124.MenuCubit>(
    () => _i124.MenuCubit(gh<_i123.GetMenuEntries>()),
  );
  await gh.singletonAsync<_i460.SharedPreferences>(
    () => registerModule.prefs,
    preResolve: true,
  );
  gh.factory<_i222.AppLocaleCubit>(
    () => _i222.AppLocaleCubit(gh<_i460.SharedPreferences>()),
  );
  gh.factory<_i223.AppThemeCubit>(
    () => _i223.AppThemeCubit(gh<_i460.SharedPreferences>()),
  );
  return getIt;
}

class _$RegisterModule extends _i539.RegisterModule {}
