import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/core/usecases/use_case.dart';
import 'package:sandbox/features/menu/domain/entities/menu_entry.dart';
import 'package:sandbox/features/menu/domain/usecases/get_menu_entries.dart';

enum MenuStatus { initial, loading, success, empty, failure }

class MenuState extends Equatable {
  const MenuState({
    this.status = MenuStatus.initial,
    this.entries = const [],
  });

  final MenuStatus status;
  final List<MenuEntry> entries;

  @override
  List<Object> get props => [status, entries];
}

@injectable
class MenuCubit extends Cubit<MenuState> {
  MenuCubit(this._getMenuEntries) : super(const MenuState());

  final GetMenuEntries _getMenuEntries;

  Future<void> load() async {
    emit(const MenuState(status: MenuStatus.loading));
    final result = await _getMenuEntries(NoParams());
    result.fold(
      (_) => emit(const MenuState(status: MenuStatus.failure)),
      (entries) => emit(
        MenuState(
          status: entries.isEmpty ? MenuStatus.empty : MenuStatus.success,
          entries: entries,
        ),
      ),
    );
  }
}
