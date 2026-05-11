<?php

namespace App\State;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Dossier;
use App\Enum\StatutDossier;
use App\Message\SendNotificationMessage;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Symfony\Component\Messenger\MessageBusInterface;

class ApprouverDossierProcessor implements ProcessorInterface
{
    public function __construct(
        private EntityManagerInterface $em,
        private Security $security,
        private MessageBusInterface $bus,
    ) {}

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): Dossier
    {
        /** @var Dossier $dossier */
        $dossier = $data;

        // Vérification du rôle
        if (!$this->security->isGranted('ROLE_DIRECTEUR')) {
            throw new AccessDeniedHttpException('Seul le Directeur peut approuver un dossier.');
        }

        // Vérification du statut
        if ($dossier->getStatut() !== StatutDossier::SIGNATURE_DIR) {
            throw new BadRequestHttpException('Ce dossier n\'est pas en attente de signature.');
        }

        $dossier->setStatut(StatutDossier::APPROUVE);
        $this->em->flush();

        //Notification FCM
        foreach ($dossier->getProprietaire()->getDeviceTokens() as $deviceToken) {
            $this->bus->dispatch(new SendNotificationMessage(
                deviceToken: $deviceToken->getToken(),
                title: '✅ Dossier approuvé',
                body: 'Votre dossier ' . $dossier->getNumeroReference() . ' a été approuvé. Vous pouvez venir le retirer.',
                data: [
                    'dossier_id' => $dossier->getId(),
                    'statut'     => $dossier->getStatut()->value,
                ]
            ));
        }
        return $dossier;
    }
}
