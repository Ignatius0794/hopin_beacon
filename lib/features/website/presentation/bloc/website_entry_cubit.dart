import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/usecases/get_saved_website.dart';
import 'package:qbyt/features/website/domain/usecases/save_website.dart';
import 'package:qbyt/features/website/presentation/helpers/website_messages.dart';

enum WebsiteEntryStatus { loading, ready, saving, opened, error }

class WebsiteEntryState extends Equatable {
  const WebsiteEntryState(this.status, {this.address = '', this.error});
  final WebsiteEntryStatus status;
  final String address;
  final String? error;

  @override
  List<Object?> get props => [status, address, error];
}

@injectable
class WebsiteEntryCubit extends Cubit<WebsiteEntryState> {
  WebsiteEntryCubit(this._getSaved, this._save)
      : super(const WebsiteEntryState(WebsiteEntryStatus.loading));
  final GetSavedWebsite _getSaved;
  final SaveWebsite _save;

  Future<void> restore() async {
    final result = await _getSaved(NoParams());
    if (isClosed) return;
    result.fold(
      (_) => emit(const WebsiteEntryState(WebsiteEntryStatus.error,
          error: 'Could not read your saved address. Enter it again.')),
      (address) => emit(
          WebsiteEntryState(WebsiteEntryStatus.ready, address: address ?? '')),
    );
  }

  Future<void> open(String input) async {
    if (state.status == WebsiteEntryStatus.saving) return;
    emit(WebsiteEntryState(WebsiteEntryStatus.saving, address: input));
    final result = await _save(input);
    if (isClosed) return;
    result.fold(
      (failure) => emit(WebsiteEntryState(WebsiteEntryStatus.error,
          address: input,
          error: failure is InvalidWebsiteAddress
              ? WebsiteMessages.invalidAddress
              : 'Could not save your address. Please try again.')),
      (address) =>
          emit(WebsiteEntryState(WebsiteEntryStatus.opened, address: address)),
    );
  }
}
