import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/dossier.dart';
import '../../repositories/dossier_repository.dart';

enum DetailStatus { loading, loaded, error }

class DossierDetailState extends Equatable {
  final DetailStatus status;
  final Dossier? dossier;

  /// La classification IA est encore en cours côté serveur (polling actif).
  final bool classificationEnCours;
  final String? error;

  const DossierDetailState({
    this.status = DetailStatus.loading,
    this.dossier,
    this.classificationEnCours = false,
    this.error,
  });

  DossierDetailState copyWith({
    DetailStatus? status,
    Dossier? dossier,
    bool? classificationEnCours,
    String? error,
  }) {
    return DossierDetailState(
      status: status ?? this.status,
      dossier: dossier ?? this.dossier,
      classificationEnCours:
          classificationEnCours ?? this.classificationEnCours,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, dossier, classificationEnCours, error];
}

class DossierDetailCubit extends Cubit<DossierDetailState> {
  final DossierRepository _repo;

  DossierDetailCubit(this._repo) : super(const DossierDetailState());

  static const _maxTentatives = 8;
  static const _delai = Duration(seconds: 2);

  /// Charge le dossier puis, tant que l'IA n'a pas renvoyé de catégorie,
  /// rafraîchit périodiquement pour faire apparaître le badge en direct.
  Future<void> load(int id) async {
    try {
      var dossier = await _repo.fetchOne(id);
      emit(DossierDetailState(
        status: DetailStatus.loaded,
        dossier: dossier,
        classificationEnCours: !dossier.estClasse,
      ));

      var tentatives = 0;
      while (!dossier.estClasse && tentatives < _maxTentatives) {
        await Future.delayed(_delai);
        if (isClosed) return;
        tentatives++;
        dossier = await _repo.fetchOne(id);
        emit(state.copyWith(
          dossier: dossier,
          classificationEnCours: !dossier.estClasse,
        ));
      }
      if (!isClosed) {
        emit(state.copyWith(classificationEnCours: false));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
          status: DetailStatus.error,
          error: 'Impossible de charger le dossier.',
        ));
      }
    }
  }
}
