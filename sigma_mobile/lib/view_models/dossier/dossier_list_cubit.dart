import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/dossier.dart';
import '../../repositories/dossier_repository.dart';

enum DossierListStatus { initial, loading, loaded, error }

class DossierListState extends Equatable {
  final DossierListStatus status;
  final List<Dossier> dossiers;
  final String? error;

  const DossierListState({
    this.status = DossierListStatus.initial,
    this.dossiers = const [],
    this.error,
  });

  int get enCours => dossiers
      .where((d) => !['APPROUVE', 'REJETE'].contains(d.statut))
      .length;
  int get approuves => dossiers.where((d) => d.statut == 'APPROUVE').length;
  int get rejetes => dossiers.where((d) => d.statut == 'REJETE').length;
  int get total => dossiers.length;

  DossierListState copyWith({
    DossierListStatus? status,
    List<Dossier>? dossiers,
    String? error,
  }) {
    return DossierListState(
      status: status ?? this.status,
      dossiers: dossiers ?? this.dossiers,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, dossiers, error];
}

class DossierListCubit extends Cubit<DossierListState> {
  final DossierRepository _repo;

  DossierListCubit(this._repo) : super(const DossierListState());

  Future<void> load() async {
    emit(state.copyWith(status: DossierListStatus.loading, error: null));
    try {
      final dossiers = await _repo.fetchAll();
      dossiers.sort((a, b) => b.id.compareTo(a.id)); // plus récents en premier
      emit(state.copyWith(
        status: DossierListStatus.loaded,
        dossiers: dossiers,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: DossierListStatus.error,
        error: 'Impossible de charger vos dossiers.',
      ));
    }
  }
}
