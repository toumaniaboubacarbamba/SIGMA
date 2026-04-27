<?php

namespace App\Controller;

use App\Entity\Dossier;
use App\Repository\DossierRepository;
use App\Repository\EtapeRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;
use Symfony\Component\HttpFoundation\Request;
use App\Message\SendNotificationMessage;
use Symfony\Component\Messenger\MessageBusInterface;

final class AgentController extends AbstractController
{
    #[Route('/dashboard', name: 'app_dashboard')]
    #[IsGranted('ROLE_AGENT')]
    public function dashboard(): Response
    {
        return $this->render('agent/dashboard.html.twig');
    }

    #[Route('/dossiers', name: 'app_dossiers')]
    #[IsGranted('ROLE_AGENT')]
    public function dossiers(DossierRepository $dossierRepository): Response
    {
        $dossiers = $dossierRepository->findAll();
        return $this->render('agent/dossiers.html.twig',[
            'dossiers' => $dossiers,
        ]);
    }

    #[Route('/dossier/{id}', name: 'app_dossier_detail')]
    #[IsGranted('ROLE_AGENT')]
    public function dossierDetail(Dossier $dossier, EtapeRepository $etapeRepository): Response {

        $etapes = $etapeRepository->findBy([], ['ordre_sequence' => 'ASC']);
        return $this->render('agent/dossier_detail.html.twig', [
            'dossier' => $dossier,
            'etapes' => $etapes,
        ]);

    }

   #[Route('/dossiers/{id}/valider', name: 'app_dossier_valider', methods: ['POST'])]
#[IsGranted('ROLE_AGENT')]
public function valider(
    Dossier $dossier,
    Request $request,
    EtapeRepository $etapeRepository,
    EntityManagerInterface $em,
    MessageBusInterface $bus
): Response {
    if (!$this->isCsrfTokenValid('valider_dossier', $request->request->get('_token'))) {
        $this->addFlash('error', 'Token invalide.');
        return $this->redirectToRoute('app_dossier_detail', ['id' => $dossier->getId()]);
    }

    $etapeId = $request->request->get('etape_id');
    $commentaire = $request->request->get('commentaire');
    $etape = $etapeRepository->find($etapeId);

    if (!$etape) {
        $this->addFlash('error', 'Étape introuvable.');
        return $this->redirectToRoute('app_dossier_detail', ['id' => $dossier->getId()]);
    }

    $dossier->setStatutActuel($etape);

    $historique = new \App\Entity\HistoriqueStatut();
    $historique->setDossier($dossier);
    $historique->setEtape($etape);
    $historique->setDateEntree(new \DateTime());
    $historique->setCommentaireAgent($commentaire ?: null);

    $em->persist($historique);
    $em->flush();
    
    // Envoi notification FCM
    $deviceTokens = $dossier->getProprietaire()->getDeviceTokens();
    foreach ($deviceTokens as $deviceToken) {
        $bus->dispatch(new SendNotificationMessage(
            $deviceToken->getToken(),
            'Dossier mis à jour',
            "Votre dossier {$dossier->getNumeroReference()} — {$etape->getLibelle()}",
            ['dossier_id' => $dossier->getId()]
        ));
    }

    $this->addFlash('success', 'Étape validée avec succès.');
    return $this->redirectToRoute('app_dossier_detail', ['id' => $dossier->getId()]);
}

}
