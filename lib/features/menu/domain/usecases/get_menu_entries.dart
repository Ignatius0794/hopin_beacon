import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/core/exceptions/failures.dart';
import 'package:sandbox/core/usecases/use_case.dart';
import 'package:sandbox/features/menu/domain/entities/menu_entry.dart';
import 'package:sandbox/features/menu/domain/repositories/menu_repository.dart';

@injectable
class GetMenuEntries implements UseCase<List<MenuEntry>, NoParams> {
  const GetMenuEntries(this._repository);

  final MenuRepository _repository;

  @override
  Future<Either<Failure, List<MenuEntry>>> call(NoParams params) =>
      _repository.getEntries();
}
