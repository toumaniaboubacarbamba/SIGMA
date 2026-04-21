<?php

namespace App\EventSubscriber;

use App\Entity\Dossier;
use App\Service\ReferenceGeneratorService;
use Doctrine\Bundle\DoctrineBundle\Attribute\AsEntityListener;
use Doctrine\ORM\Events;

#[AsEntityListener(event: Events::prePersist, entity: Dossier::class)]
class DossierSubscriber
{
    public function __construct(
        private ReferenceGeneratorService $referenceGenerator
    ) {}

    public function prePersist(Dossier $dossier): void
    {
        $dossier->setNumeroReference(
            $this->referenceGenerator->generate()
        );
    }
}
