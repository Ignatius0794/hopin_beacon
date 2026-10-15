import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/usecases/get_website_menu_tip.dart';
import 'package:qbyt/features/website/domain/usecases/dismiss_website_menu_tip.dart';

@injectable
class WebsiteMenuTipCubit extends Cubit<bool> {
  WebsiteMenuTipCubit(this._getTip, this._dismissTip) : super(false);
  final GetWebsiteMenuTip _getTip;
  final DismissWebsiteMenuTip _dismissTip;
  bool _checked = false;
  bool _dismissed = false;

  Future<void> showAfterSuccess() async {
    if (_checked) return;
    _checked = true;
    final result = await _getTip(NoParams());
    if (isClosed || _dismissed) return;
    // A failed preference read must not hide the only controls hint.
    emit(result.getOrElse(() => true));
  }

  Future<void> dismiss() async {
    _dismissed = true;
    emit(false);
    await _dismissTip(NoParams());
  }
}
