import 'package:dartz/dartz.dart';
import 'package:qbyt/core/exceptions/failures.dart';

abstract class WebsiteRepository {
  Future<Either<Failure, String?>> getSavedAddress();
  Future<Either<Failure, void>> saveAddress(String address);
  Future<Either<Failure, void>> clearAddress();
  Future<Either<Failure, String?>> getPreviousAddress();
  Future<Either<Failure, void>> savePreviousAddress(String address);
  Future<Either<Failure, void>> clearPreviousAddress();
  Future<Either<Failure, bool>> hasSeenMenuTip();
  Future<Either<Failure, void>> markMenuTipSeen();
}
