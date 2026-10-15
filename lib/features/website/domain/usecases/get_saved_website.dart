import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/exceptions/failures.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/domain/repositories/website_repository.dart';

@injectable
class GetSavedWebsite extends UseCase<String?, NoParams> {
  GetSavedWebsite(this._repository);
  final WebsiteRepository _repository;

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    final result = await _repository.getSavedAddress();
    return result
        .map((address) => WebsiteAddress.tryParse(address ?? '')?.value);
  }
}
