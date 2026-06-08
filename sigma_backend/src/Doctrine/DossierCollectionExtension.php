<?php

namespace App\Doctrine;

use ApiPlatform\Doctrine\Orm\Extension\QueryCollectionExtensionInterface;
use ApiPlatform\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use ApiPlatform\Metadata\Operation;
use App\Entity\Dossier;
use App\Entity\User;
use Doctrine\ORM\QueryBuilder;
use Symfony\Bundle\SecurityBundle\Security;

/**
 * Restreint la collection de dossiers : un citoyen ne voit que ses propres
 * dossiers. Les agents et le directeur continuent de voir l'ensemble.
 */
final class DossierCollectionExtension implements QueryCollectionExtensionInterface
{
    public function __construct(
        private Security $security,
    ) {}

    public function applyToCollection(
        QueryBuilder $queryBuilder,
        QueryNameGeneratorInterface $queryNameGenerator,
        string $resourceClass,
        ?Operation $operation = null,
        array $context = [],
    ): void {
        if ($resourceClass !== Dossier::class) {
            return;
        }

        $user = $this->security->getUser();
        if (!$user instanceof User) {
            return;
        }

        // Les agents et directeurs ont une vue globale.
        if ($this->security->isGranted('ROLE_AGENT') || $this->security->isGranted('ROLE_DIRECTEUR')) {
            return;
        }

        $alias = $queryBuilder->getRootAliases()[0];
        $queryBuilder
            ->andWhere(sprintf('%s.proprietaire = :current_user', $alias))
            ->setParameter('current_user', $user);
    }
}
