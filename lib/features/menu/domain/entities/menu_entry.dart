import 'package:equatable/equatable.dart';

class MenuEntry extends Equatable {
  const MenuEntry({required this.id, required this.titleKey});

  final String id;
  final String titleKey;

  @override
  List<Object> get props => [id, titleKey];
}
