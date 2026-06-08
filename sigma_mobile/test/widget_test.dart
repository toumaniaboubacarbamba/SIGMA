import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigma_mobile/entities/dossier.dart';
import 'package:sigma_mobile/ui/widgets/common/sigma_category_badge.dart';

void main() {
  testWidgets('Le badge IA affiche la catégorie et le score', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SigmaCategoryBadge(
            categorie: 'PERMIS_CONSTRUIRE',
            scorePourcent: 98,
          ),
        ),
      ),
    );

    expect(find.text('Permis de construire'), findsOneWidget);
    expect(find.text('· 98%'), findsOneWidget);
  });

  test('Dossier.fromJson lit la classification IA', () {
    final dossier = Dossier.fromJson({
      'id': 30,
      'numero_reference': 'SIGMA-2026-00004',
      'statut': 'SOUMIS',
      'categorieIa': 'PERMIS_CONSTRUIRE',
      'scoreConfianceIa': 0.98,
    });

    expect(dossier.estClasse, isTrue);
    expect(dossier.scorePourcent, 98);
    expect(dossier.categorieIa, 'PERMIS_CONSTRUIRE');
  });
}
