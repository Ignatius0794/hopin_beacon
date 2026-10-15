import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qbyt/core/di/injection.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/presentation/bloc/website_entry_cubit.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_cubit.dart';
import 'package:qbyt/features/website/presentation/bloc/website_menu_tip_cubit.dart';
import 'package:qbyt/features/website/presentation/screen/website_entry_screen.dart';
import 'package:qbyt/features/website/presentation/screen/website_browser_screen.dart';

abstract class WebsiteRoutes {
  static const entryName = 'website-entry';
  static const entryPath = '/main';
  static const browserName = 'website-browser';
  static const browserPath = '/web';

  static List<GoRoute> get routes => [
        GoRoute(
          name: entryName,
          path: entryPath,
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<WebsiteEntryCubit>()..restore(),
            child: const WebsiteEntryScreen(),
          ),
        ),
        GoRoute(
          name: browserName,
          path: browserPath,
          redirect: (context, state) => state.extra is String &&
                  WebsiteAddress.tryParse(state.extra! as String) != null
              ? null
              : entryPath,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<WebsiteMenuCubit>()),
              BlocProvider(create: (_) => getIt<WebsiteMenuTipCubit>()),
            ],
            child: WebsiteBrowserScreen(url: state.extra! as String),
          ),
        ),
      ];
}
