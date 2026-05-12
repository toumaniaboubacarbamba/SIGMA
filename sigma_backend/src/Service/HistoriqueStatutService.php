<?php

namespace App\Service;

use App\Entity\Dossier;
use App\Entity\HistoriqueStatut;
use App\Entity\Etape;
use App\Enum\StatutDossier;
use Doctrine\ORM\EntityManagerInterface;

class HistoriqueStatutService
{
    public function __construct(
        private EntityManagerInterface $em,
    ) {}

    public function enregistrerTransition(
        Dossier $dossier,
        StatutDossier $nouveauStatut,
        ?string $commentaire = null
    ): void {
        // Fermer l'entrée précédente
        $dernier = $this->em->getRepository(HistoriqueStatut::class)
            ->findOneBy(
                ['dossier' => $dossier, 'date_sortie' => null],
                ['date_entree' => 'DESC']
            );

        if ($dernier) {
            $dernier->setDateSortie(new \DateTime());
        }

        // Créer la nouvelle entrée
        $historique = new HistoriqueStatut();
        $historique->setDossier($dossier);
        $historique->setStatut($nouveauStatut);
        $historique->setDateEntree(new \DateTime());
        $historique->setCommentaireAgent($commentaire);

        // Lier à l'Etape correspondante si elle existe
        $etape = $this->em->getRepository(Etape::class)
            ->findOneBy(['libelle' => $nouveauStatut->value]);
        if ($etape) {
            $historique->setEtape($etape);
        }

        $this->em->persist($historique);
    }
}
