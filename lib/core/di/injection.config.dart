// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:qbyt/core/di/register_module.dart' as _i539;
import 'package:qbyt/core/routes/app_router.dart' as _i693;
import 'package:qbyt/core/theme/app_theme.dart' as _i599;
import 'package:qbyt/features/website/data/datasources/website_local_datasource.dart'
    as _i157;
import 'package:qbyt/features/website/data/repositories/website_repository_impl.dart'
    as _i745;
import 'package:qbyt/features/website/domain/repositories/website_repository.dart'
    as _i645;
import 'package:qbyt/features/website/domain/usecases/clear_saved_website.dart'
    as _i593;
import 'package:qbyt/features/website/domain/usecases/clear_previous_website.dart'
    as _i201;
import 'package:qbyt/features/website/domain/usecases/dismiss_website_menu_tip.dart'
    as _i997;
import 'package:qbyt/features/website/domain/usecases/get_saved_website.dart'
    as _i393;
import 'package:qbyt/features/website/domain/usecases/get_previous_website.dart'
    as _i202;
import 'package:qbyt/features/website/domain/usecases/get_website_menu_tip.dart'
    as _i169;
import 'package:qbyt/features/website/domain/usecases/save_website.dart'
    as _i1004;
import 'package:qbyt/features/website/domain/usecases/save_previous_website.dart'
    as _i203;
import 'package:qbyt/features/website/presentation/bloc/website_entry_cubit.dart'
    as _i844;
import 'package:qbyt/features/website/presentation/bloc/website_menu_cubit.dart'
    as _i978;
import 'package:qbyt/features/website/presentation/bloc/website_menu_tip_cubit.dart'
    as _i468;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  gh.factory<_i599.AppTheme>(() => _i599.AppTheme());
  await gh.singletonAsync<_i460.SharedPreferences>(
    () => registerModule.prefs,
    preResolve: true,
  );
  gh.factory<_i157.WebsiteLocalDataSource>(
      () => _i157.WebsiteLocalDataSource(gh<_i460.SharedPreferences>()));
  gh.factory<_i645.WebsiteRepository>(
      () => _i745.WebsiteRepositoryImpl(gh<_i157.WebsiteLocalDataSource>()));
  gh.factory<_i1004.SaveWebsite>(
      () => _i1004.SaveWebsite(gh<_i645.WebsiteRepository>()));
  gh.factory<_i393.GetSavedWebsite>(
      () => _i393.GetSavedWebsite(gh<_i645.WebsiteRepository>()));
  gh.factory<_i693.AppRouter>(
      () => _i693.AppRouter(gh<_i393.GetSavedWebsite>()));
  gh.factory<_i593.ClearSavedWebsite>(
      () => _i593.ClearSavedWebsite(gh<_i645.WebsiteRepository>()));
  gh.factory<_i201.ClearPreviousWebsite>(
      () => _i201.ClearPreviousWebsite(gh<_i645.WebsiteRepository>()));
  gh.factory<_i202.GetPreviousWebsite>(
      () => _i202.GetPreviousWebsite(gh<_i645.WebsiteRepository>()));
  gh.factory<_i203.SavePreviousWebsite>(
      () => _i203.SavePreviousWebsite(gh<_i645.WebsiteRepository>()));
  gh.factory<_i169.GetWebsiteMenuTip>(
      () => _i169.GetWebsiteMenuTip(gh<_i645.WebsiteRepository>()));
  gh.factory<_i997.DismissWebsiteMenuTip>(
      () => _i997.DismissWebsiteMenuTip(gh<_i645.WebsiteRepository>()));
  gh.factory<_i468.WebsiteMenuTipCubit>(() => _i468.WebsiteMenuTipCubit(
        gh<_i169.GetWebsiteMenuTip>(),
        gh<_i997.DismissWebsiteMenuTip>(),
      ));
  gh.factory<_i978.WebsiteMenuCubit>(() => _i978.WebsiteMenuCubit(
        gh<_i593.ClearSavedWebsite>(),
        gh<_i1004.SaveWebsite>(),
        gh<_i202.GetPreviousWebsite>(),
        gh<_i203.SavePreviousWebsite>(),
        gh<_i201.ClearPreviousWebsite>(),
      ));
  gh.factory<_i844.WebsiteEntryCubit>(() => _i844.WebsiteEntryCubit(
        gh<_i393.GetSavedWebsite>(),
        gh<_i1004.SaveWebsite>(),
      ));
  return getIt;
}

class _$RegisterModule extends _i539.RegisterModule {}
