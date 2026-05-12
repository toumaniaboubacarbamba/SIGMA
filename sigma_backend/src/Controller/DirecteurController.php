<?php

namespace App\Controller;

use App\Entity\Dossier;
use App\Enum\StatutDossier;
use App\Repository\DossierRepository;
use App\Repository\HistoriqueStatutRepository;
use App\Service\HistoriqueStatutService;
use App\Message\SendNotificationMessage;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/directeur')]
#[IsGranted('ROLE_DIRECTEUR')]
final class DirecteurController extends AbstractController
{
    #[Route('/dashboard', name: 'directeur_dashboard')]
    public function dashboard(
        DossierRepository $dossierRepository,
        HistoriqueStatutRepository $historiqueRepo
    ): Response {
        $enAttente = $dossierRepository->count(['statut' => StatutDossier::SIGNATURE_DIR]);
        $approuves = $dossierRepository->count(['statut' => StatutDossier::APPROUVE]);
        $rejetes   = $dossierRepository->count(['statut' => StatutDossier::REJETE]);

        return $this->render('directeur/dashboard.html.twig', [
            'en_attente'       => $enAttente,
            'approuves'        => $approuves,
            'rejetes'          => $rejetes,
            'dmt'              => $historiqueRepo->calculerDMT(),
            'taux_approbation' => $historiqueRepo->calculerTauxApprobation(),
        ]);
    }

    #[Route('/dossiers', name: 'directeur_dossiers')]
    public function dossiers(DossierRepository $dossierRepository): Response
    {
        $dossiers = $dossierRepository->findBy(['statut' => StatutDossier::SIGNATURE_DIR]);
        return $this->render('directeur/dossiers.html.twig', [
            'dossiers' => $dossiers,
        ]);
    }

    #[Route('/dossier/{id}', name: 'directeur_dossier_detail')]
    public function dossierDetail(Dossier $dossier): Response
    {
        return $this->render('directeur/dossier_detail.html.twig', [
            'dossier' => $dossier,
        ]);
    }

    #[Route('/dossier/{id}/approuver', name: 'directeur_approuver', methods: ['POST'])]
    public function approuver(
        Dossier $dossier,
        Request $request,
        EntityManagerInterface $em,
        MessageBusInterface $bus,
        HistoriqueStatutService $historiqueService
    ): Response {
        if (!$this->isCsrfTokenValid('decision_dossier', $request->request->get('_token'))) {
            $this->addFlash('error', 'Token invalide.');
            return $this->redirectToRoute('directeur_dossier_detail', ['id' => $dossier->getId()]);
        }

        if ($dossier->getStatut() !== StatutDossier::SIGNATURE_DIR) {
            $this->addFlash('error', 'Ce dossier n\'est pas en attente de signature.');
            return $this->redirectToRoute('directeur_dossier_detail', ['id' => $dossier->getId()]);
        }

        $dossier->setStatut(StatutDossier::APPROUVE);
        $historiqueService->enregistrerTransition($dossier, StatutDossier::APPROUVE, 'Approuvé par le Directeur');
        $em->flush();

        foreach ($dossier->getProprietaire()->getDeviceTokens() as $deviceToken) {
            $bus->dispatch(new SendNotificationMessage(
                deviceToken: $deviceToken->getToken(),
                title: '✅ Dossier approuvé',
                body: 'Votre dossier ' . $dossier->getNumeroReference() . ' a été approuvé.',
                data: ['dossier_id' => $dossier->getId(), 'statut' => StatutDossier::APPROUVE->value]
            ));
        }

        $this->addFlash('success', 'Dossier approuvé avec succès.');
        return $this->redirectToRoute('directeur_dossiers');
    }

    #[Route('/dossier/{id}/rejeter', name: 'directeur_rejeter', methods: ['POST'])]
    public function rejeter(
        Dossier $dossier,
        Request $request,
        EntityManagerInterface $em,
        MessageBusInterface $bus,
        HistoriqueStatutService $historiqueService
    ): Response {
        if (!$this->isCsrfTokenValid('decision_dossier', $request->request->get('_token'))) {
            $this->addFlash('error', 'Token invalide.');
            return $this->redirectToRoute('directeur_dossier_detail', ['id' => $dossier->getId()]);
        }

        $motif = $request->request->get('motif_rejet');
        if (empty($motif)) {
            $this->addFlash('error', 'Le motif de rejet est obligatoire.');
            return $this->redirectToRoute('directeur_dossier_detail', ['id' => $dossier->getId()]);
        }

        $dossier->setMotifRejet($motif);
        $dossier->setStatut(StatutDossier::REJETE);
        $historiqueService->enregistrerTransition($dossier, StatutDossier::REJETE, 'Rejeté. Motif : ' . $motif);
        $em->flush();

        foreach ($dossier->getProprietaire()->getDeviceTokens() as $deviceToken) {
            $bus->dispatch(new SendNotificationMessage(
                deviceToken: $deviceToken->getToken(),
                title: '❌ Dossier rejeté',
                body: 'Votre dossier ' . $dossier->getNumeroReference() . ' a été rejeté. Motif : ' . $motif,
                data: ['dossier_id' => $dossier->getId(), 'statut' => StatutDossier::REJETE->value]
            ));
        }

        $this->addFlash('success', 'Dossier rejeté.');
        return $this->redirectToRoute('directeur_dossiers');
    }
}
