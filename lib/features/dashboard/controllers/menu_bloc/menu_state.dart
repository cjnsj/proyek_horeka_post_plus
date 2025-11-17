import 'package:equatable/equatable.dart';

abstract class MenuState extends Equatable {
  const MenuState();
  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  // Kita simpan daftar produk di sini
  final List<dynamic> products;
  
  const MenuLoaded({required this.products});
  
  @override
  List<Object> get props => [products];
}

class MenuError extends MenuState {
  final String message;
  
  const MenuError({required this.message});
  
  @override
  List<Object> get props => [message];
}