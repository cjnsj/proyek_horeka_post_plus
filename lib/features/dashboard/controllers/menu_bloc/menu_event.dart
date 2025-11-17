import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();
  @override
  List<Object> get props => [];
}

/// Event untuk memicu pengambilan data menu
class FetchMenuEvent extends MenuEvent {}