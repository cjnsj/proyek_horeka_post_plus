import 'package:bloc/bloc.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_event.dart';
import 'package:horeka_post_plus/features/dashboard/controllers/menu_bloc/menu_state.dart';
import 'package:horeka_post_plus/features/dashboard/services/menu_api_service.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuApiService apiService;

  MenuBloc({required this.apiService}) : super(MenuInitial()) {
    // Daftarkan handler untuk event FetchMenuEvent
    on<FetchMenuEvent>(_onFetchMenu);
  }

  Future<void> _onFetchMenu(
      FetchMenuEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final products = await apiService.getMenu();
      emit(MenuLoaded(products: products));
    } catch (e) {
      emit(MenuError(message: e.toString()));
    }
  }
}