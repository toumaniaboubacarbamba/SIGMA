<?php
namespace App\Service;

use App\Repository\DossierRepository;

class ReferenceGeneratorService{
    public function __construct(
        private DossierRepository $dossier_repository
    ){}

    public function generate(): string
    {
        $annee = date('Y');
        $count = $this->dossier_repository->countByYear($annee);
        $numero = str_pad($count +1, 5, '0', STR_PAD_LEFT);

        return "SIGMA-{$annee}-{$numero}";
    }
}
