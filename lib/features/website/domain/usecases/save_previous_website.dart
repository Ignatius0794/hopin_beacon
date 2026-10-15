import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/exceptions/failures.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/repositories/website_repository.dart';

@injectable
class SavePreviousWebsite extends UseCase<void, String> {
  SavePreviousWebsite(this._repository);
  final WebsiteRepository _repository;

  @override
  Future<Either<Failure, void>> call(String params) =>
      _repository.savePreviousAddress(params);
}
