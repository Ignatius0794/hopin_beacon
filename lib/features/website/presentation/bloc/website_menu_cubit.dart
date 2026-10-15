import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/entities/website_address.dart';
import 'package:qbyt/features/website/domain/usecases/clear_saved_website.dart';
import 'package:qbyt/features/website/domain/usecases/clear_previous_website.dart';
import 'package:qbyt/features/website/domain/usecases/get_previous_website.dart';
import 'package:qbyt/features/website/domain/usecases/save_previous_website.dart';
import 'package:qbyt/features/website/domain/usecases/save_website.dart';
import 'package:qbyt/features/website/presentation/helpers/website_messages.dart';

enum WebsiteMenuState { ready, resetting, reset, error }

@injectable
class WebsiteMenuCubit extends Cubit<WebsiteMenuState> {
  WebsiteMenuCubit(
    this._clearSavedWebsite,
    this._saveWebsite,
    this._getPreviousWebsite,
    this._savePreviousWebsite,
    this._clearPreviousWebsite,
  ) : super(WebsiteMenuState.ready);
  final ClearSavedWebsite _clearSavedWebsite;
  final SaveWebsite _saveWebsite;
  final GetPreviousWebsite _getPreviousWebsite;
  final SavePreviousWebsite _savePreviousWebsite;
  final ClearPreviousWebsite _clearPreviousWebsite;
  static const _persistenceTimeout = Duration(seconds: 5);

  Future<WebsiteUrlChangeResult> changeUrl(
    String input, {
    required String previousUrl,
  }) async {
    final normalized = WebsiteAddress.tryParse(input)?.value;
    if (normalized == null) {
      return const WebsiteUrlChangeResult(
        error: WebsiteMessages.invalidAddress,
      );
    }
    if (normalized == previousUrl) {
      return const WebsiteUrlChangeResult(
        error: 'Enter a different website address.',
      );
    }
    try {
      final backup =
          await _savePreviousWebsite(previousUrl).timeout(_persistenceTimeout);
      if (backup.isLeft()) {
        return const WebsiteUrlChangeResult(
          error: 'Could not protect your current address. Please try again.',
        );
      }
      final result = await _saveWebsite(input).timeout(_persistenceTimeout);
      return await result.fold(
        (failure) async {
          await _clearBackupQuietly();
          return WebsiteUrlChangeResult(
            error: failure is InvalidWebsiteAddress
                ? WebsiteMessages.invalidAddress
                : 'Could not save your new address. Please try again.',
          );
        },
        (address) async => WebsiteUrlChangeResult(address: address),
      );
    } on TimeoutException {
      await _clearBackupQuietly();
      return const WebsiteUrlChangeResult(
        error: 'Saving took too long. Check your device and try again.',
      );
    }
  }

  Future<String?> loadPreviousUrl() async {
    try {
      final result =
          await _getPreviousWebsite(NoParams()).timeout(_persistenceTimeout);
      return result.getOrElse(() => null);
    } on TimeoutException {
      return null;
    }
  }

  Future<WebsiteUrlChangeResult> restorePreviousUrl(String address) async {
    try {
      final result = await _saveWebsite(address).timeout(_persistenceTimeout);
      if (result.isLeft()) {
        return const WebsiteUrlChangeResult(
          error: 'Could not restore the previous website. Please try again.',
        );
      }
      await _clearBackupQuietly();
      return WebsiteUrlChangeResult(address: address);
    } on TimeoutException {
      return const WebsiteUrlChangeResult(
        error: 'Restoring took too long. Please try again.',
      );
    }
  }

  Future<void> confirmChangedUrlLoaded() => _clearBackupQuietly();

  Future<void> _clearBackupQuietly() async {
    try {
      await _clearPreviousWebsite(NoParams()).timeout(_persistenceTimeout);
    } on TimeoutException {
      // A later successful launch will make another cleanup attempt.
    }
  }

  Future<void> resetUrl() async {
    if (state == WebsiteMenuState.resetting) return;
    emit(WebsiteMenuState.resetting);
    try {
      final result =
          await _clearSavedWebsite(NoParams()).timeout(_persistenceTimeout);
      if (isClosed) return;
      result.fold(
        (_) => emit(WebsiteMenuState.error),
        (_) => emit(WebsiteMenuState.reset),
      );
    } on TimeoutException {
      if (!isClosed) emit(WebsiteMenuState.error);
    }
  }
}

class WebsiteUrlChangeResult {
  const WebsiteUrlChangeResult({this.address, this.error});

  final String? address;
  final String? error;

  bool get succeeded => address != null;
}
