import 'package:dartz/dartz.dart';

import 'package:sandbox/core/exceptions/failures.dart';
import 'package:sandbox/features/menu/domain/entities/menu_entry.dart';

abstract class MenuRepository {
  Future<Either<Failure, List<MenuEntry>>> getEntries();
}
