import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/exceptions/failures.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/repositories/website_repository.dart';

@injectable
class GetWebsiteMenuTip extends UseCase<bool, NoParams> {
  GetWebsiteMenuTip(this._repository);
  final WebsiteRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async =>
      (await _repository.hasSeenMenuTip()).map((seen) => !seen);
}
