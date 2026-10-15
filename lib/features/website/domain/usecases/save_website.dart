import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/exceptions/failures.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/domain/repositories/website_repository.dart';

class InvalidWebsiteAddress extends Failure {}

@injectable
class SaveWebsite extends UseCase<String, String> {
  SaveWebsite(this._repository);
  final WebsiteRepository _repository;

  @override
  Future<Either<Failure, String>> call(String params) async {
    final address = WebsiteAddress.tryParse(params);
    if (address == null) return Left(InvalidWebsiteAddress());
    final result = await _repository.saveAddress(address.value);
    return result.map((_) => address.value);
  }
}
