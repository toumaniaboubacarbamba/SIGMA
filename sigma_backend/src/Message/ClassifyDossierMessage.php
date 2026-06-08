<?php

namespace App\Message;

/**
 * Message déclenchant la classification IA d'un dossier en arrière-plan.
 *
 * On ne transporte que l'identifiant (pas l'entité) : le handler recharge le
 * dossier frais depuis la base, ce qui évite les problèmes de sérialisation
 * d'entités Doctrine sur un transport async.
 */
final class ClassifyDossierMessage
{
    public function __construct(
        private int $dossierId,
    ) {}

    public function getDossierId(): int
    {
        return $this->dossierId;
    }
}
