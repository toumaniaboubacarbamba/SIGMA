<?php

namespace App\Controller;

use App\Repository\HistoriqueStatutRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/api/kpis')]
#[IsGranted('ROLE_DIRECTEUR')]
class KpiController extends AbstractController
{
    public function __construct(
        private HistoriqueStatutRepository $historiqueRepo,
    ) {}

    #[Route('', name: 'api_kpis', methods: ['GET'])]
    public function index(): JsonResponse
    {
        return $this->json([
            'dmt_jours'          => $this->historiqueRepo->calculerDMT(),
            'taux_approbation'   => $this->historiqueRepo->calculerTauxApprobation(),
            'volume_par_statut'  => $this->historiqueRepo->calculerVolumeParStatut(),
        ]);
    }
}
