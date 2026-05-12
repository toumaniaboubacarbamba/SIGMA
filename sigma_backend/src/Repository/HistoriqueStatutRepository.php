<?php

namespace App\Repository;

use App\Entity\HistoriqueStatut;
use App\Enum\StatutDossier;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<HistoriqueStatut>
 */
class HistoriqueStatutRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, HistoriqueStatut::class);
    }

    //    /**
    //     * @return HistoriqueStatut[] Returns an array of HistoriqueStatut objects
    //     */
    //    public function findByExampleField($value): array
    //    {
    //        return $this->createQueryBuilder('h')
    //            ->andWhere('h.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->orderBy('h.id', 'ASC')
    //            ->setMaxResults(10)
    //            ->getQuery()
    //            ->getResult()
    //        ;
    //    }

    //    public function findOneBySomeField($value): ?HistoriqueStatut
    //    {
    //        return $this->createQueryBuilder('h')
    //            ->andWhere('h.exampleField = :val')
    //            ->setParameter('val', $value)
    //            ->getQuery()
    //            ->getOneOrNullResult()
    //        ;
    //    }

    public function calculerDMT(): float
    {
        $conn = $this->getEntityManager()->getConnection();

        $sql = "
            SELECT AVG(TIMESTAMPDIFF(DAY, h_soumis.date_entree, h_final.date_entree)) as dmt
            FROM historique_statut h_soumis
            JOIN historique_statut h_final ON h_soumis.dossier_id = h_final.dossier_id
            WHERE h_soumis.statut = :soumis
            AND h_final.statut IN (:approuve, :rejete)
        ";

        $result = $conn->executeQuery($sql, [
            'soumis'   => StatutDossier::SOUMIS->value,
            'approuve' => StatutDossier::APPROUVE->value,
            'rejete'   => StatutDossier::REJETE->value,
        ])->fetchAssociative();

        return round((float) ($result['dmt'] ?? 0), 2);
    }

    public function calculerTauxApprobation(): float
    {
        $conn = $this->getEntityManager()->getConnection();

        $sql = "
            SELECT
                COUNT(CASE WHEN statut = :approuve THEN 1 END) as approuves,
                COUNT(CASE WHEN statut IN (:approuve, :rejete) THEN 1 END) as total
            FROM historique_statut
            WHERE statut IN (:approuve, :rejete)
        ";

        $result = $conn->executeQuery($sql, [
            'approuve' => StatutDossier::APPROUVE->value,
            'rejete'   => StatutDossier::REJETE->value,
        ])->fetchAssociative();

        $total = (int) ($result['total'] ?? 0);
        if ($total === 0) return 0.0;

        return round((float) $result['approuves'] / $total * 100, 2);
    }

    public function calculerVolumeParStatut(): array
    {
        $conn = $this->getEntityManager()->getConnection();

        $sql = "
            SELECT statut, COUNT(*) as total
            FROM historique_statut
            WHERE statut IS NOT NULL
            GROUP BY statut
            ORDER BY total DESC
        ";

        return $conn->executeQuery($sql)->fetchAllAssociative();
    }
}
