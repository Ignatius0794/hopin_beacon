import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/core/exceptions/failures.dart';
import 'package:sandbox/features/menu/data/datasources/menu_local_datasource.dart';
import 'package:sandbox/features/menu/data/mappers/menu_entry_mapper.dart';
import 'package:sandbox/features/menu/domain/entities/menu_entry.dart';
import 'package:sandbox/features/menu/domain/repositories/menu_repository.dart';

@LazySingleton(as: MenuRepository)
class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl(this._dataSource);

  final MenuLocalDataSource _dataSource;

  @override
  Future<Either<Failure, List<MenuEntry>>> getEntries() async {
    try {
      final models = await _dataSource.getEntries();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
