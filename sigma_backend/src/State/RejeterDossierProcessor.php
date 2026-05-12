<?php

namespace App\State;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Dossier;
use App\Enum\StatutDossier;
use App\Message\SendNotificationMessage;
use App\Service\HistoriqueStatutService;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\Messenger\MessageBusInterface;

class RejeterDossierProcessor implements ProcessorInterface
{
    public function __construct(
        private EntityManagerInterface $em,
        private Security $security,
        private MessageBusInterface $bus,
        private HistoriqueStatutService $historiqueService,
    ) {}

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): Dossier
    {
        /** @var Dossier $dossier */
        $dossier = $data;

        if (!$this->security->isGranted('ROLE_DIRECTEUR')) {
            throw new AccessDeniedHttpException('Seul le Directeur peut rejeter un dossier.');
        }

        if ($dossier->getStatut() !== StatutDossier::SIGNATURE_DIR) {
            throw new BadRequestHttpException('Ce dossier n\'est pas en attente de signature.');
        }

        $motif = $context['request']->toArray()['motif_rejet'] ?? null;
        if (empty($motif)) {
            throw new BadRequestHttpException('Le motif de rejet est obligatoire.');
        }

        $dossier->setMotifRejet($motif);
        $dossier->setStatut(StatutDossier::REJETE);

        // Enregistrement de la transition
        $this->historiqueService->enregistrerTransition(
            $dossier,
            StatutDossier::REJETE,
            'Rejeté par le Directeur. Motif : ' . $motif
        );

        $this->em->flush();

        // Notification FCM
        foreach ($dossier->getProprietaire()->getDeviceTokens() as $deviceToken) {
            $this->bus->dispatch(new SendNotificationMessage(
                deviceToken: $deviceToken->getToken(),
                title: '❌ Dossier rejeté',
                body: 'Votre dossier ' . $dossier->getNumeroReference() . ' a été rejeté. Motif : ' . $motif,
                data: [
                    'dossier_id'  => $dossier->getId(),
                    'statut'      => $dossier->getStatut()->value,
                    'motif_rejet' => $motif,
                ]
            ));
        }

        return $dossier;
    }
}
