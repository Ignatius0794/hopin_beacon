import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: false,
  asExtension: false,
  generateForDir: ['test', 'lib', 'tests'],
)
Future<void> configureDependencies() async => init(getIt);
