import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/exceptions/failures.dart';
import 'package:qbyt/features/website/data/datasources/website_local_datasource.dart';
import 'package:qbyt/features/website/domain/repositories/website_repository.dart';

@Injectable(as: WebsiteRepository)
class WebsiteRepositoryImpl implements WebsiteRepository {
  WebsiteRepositoryImpl(this._local);
  final WebsiteLocalDataSource _local;

  @override
  Future<Either<Failure, bool>> hasSeenMenuTip() async {
    try {
      return Right(_local.hasSeenMenuTip());
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markMenuTipSeen() async {
    try {
      await _local.markMenuTipSeen();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getSavedAddress() async {
    try {
      return Right(_local.readAddress());
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearAddress() async {
    try {
      await _local.clearAddress();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveAddress(String address) async {
    try {
      await _local.saveAddress(address);
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getPreviousAddress() async {
    try {
      return Right(_local.readPreviousAddress());
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> savePreviousAddress(String address) async {
    try {
      await _local.savePreviousAddress(address);
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearPreviousAddress() async {
    try {
      await _local.clearPreviousAddress();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
