<?php

namespace App\Controller;

use App\Entity\Dossier;
use App\Enum\StatutDossier;
use App\Repository\DossierRepository;
use App\Service\HistoriqueStatutService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;
use App\Message\SendNotificationMessage;

final class AgentController extends AbstractController
{
    #[Route('/dashboard', name: 'app_dashboard')]
    #[IsGranted('ROLE_AGENT')]
    public function dashboard(DossierRepository $dossierRepository): Response
    {
        $enAttente = $dossierRepository->count(['statut' => StatutDossier::EN_ANALYSE]);
        $total     = $dossierRepository->count([]);

        return $this->render('agent/dashboard.html.twig', [
            'en_attente' => $enAttente,
            'total'      => $total,
        ]);
    }

    #[Route('/dossiers', name: 'app_dossiers')]
    #[IsGranted('ROLE_AGENT')]
    public function dossiers(DossierRepository $dossierRepository): Response
    {
        $dossiers = $dossierRepository->findAll();
        return $this->render('agent/dossiers.html.twig', [
            'dossiers' => $dossiers,
        ]);
    }

    #[Route('/dossier/{id}', name: 'app_dossier_detail')]
    #[IsGranted('ROLE_AGENT')]
    public function dossierDetail(Dossier $dossier): Response
    {
        return $this->render('agent/dossier_detail.html.twig', [
            'dossier' => $dossier,
        ]);
    }

    #[Route('/dossiers/{id}/action', name: 'app_dossier_action', methods: ['POST'])]
    #[IsGranted('ROLE_AGENT')]
    public function action(
        Dossier $dossier,
        Request $request,
        EntityManagerInterface $em,
        MessageBusInterface $bus,
        HistoriqueStatutService $historiqueService
    ): Response {
        if (!$this->isCsrfTokenValid('action_dossier', $request->request->get('_token'))) {
            $this->addFlash('error', 'Token invalide.');
            return $this->redirectToRoute('app_dossier_detail', ['id' => $dossier->getId()]);
        }

        $action = $request->request->get('action');
        $commentaire = $request->request->get('commentaire');

        // Transitions autorisées selon le statut actuel
        $transitions = [
            StatutDossier::EN_ANALYSE->value => [
                'valider'    => StatutDossier::RECEVABLE,
                'incomplet'  => StatutDossier::INCOMPLET,
            ],
            StatutDossier::RECEVABLE->value => [
                'transmettre' => StatutDossier::SIGNATURE_DIR,
            ],
        ];

        $statutActuel = $dossier->getStatut()->value;

        if (!isset($transitions[$statutActuel][$action])) {
            $this->addFlash('error', 'Action non autorisée pour ce statut.');
            return $this->redirectToRoute('app_dossier_detail', ['id' => $dossier->getId()]);
        }

        $nouveauStatut = $transitions[$statutActuel][$action];
        $dossier->setStatut($nouveauStatut);

        $historiqueService->enregistrerTransition($dossier, $nouveauStatut, $commentaire);

        $em->flush();

        // Notification FCM
        foreach ($dossier->getProprietaire()->getDeviceTokens() as $deviceToken) {
            $bus->dispatch(new SendNotificationMessage(
                deviceToken: $deviceToken->getToken(),
                title: 'Dossier mis à jour',
                body: 'Votre dossier ' . $dossier->getNumeroReference() . ' a été mis à jour.',
                data: ['dossier_id' => $dossier->getId()]
            ));
        }

        $this->addFlash('success', 'Dossier mis à jour avec succès.');
        return $this->redirectToRoute('app_dossier_detail', ['id' => $dossier->getId()]);
    }
}
