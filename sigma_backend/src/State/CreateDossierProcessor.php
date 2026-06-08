<?php

namespace App\State;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Dossier;
use App\Entity\User;
use App\Enum\StatutDossier;
use App\Message\ClassifyDossierMessage;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\Messenger\MessageBusInterface;

/**
 * Processor de création d'un dossier via l'API.
 *
 * Décore le PersistProcessor par défaut d'API Platform : il laisse celui-ci
 * persister + flusher le dossier, puis déclenche la classification IA en
 * arrière-plan (async via Messenger). La réponse HTTP n'est pas bloquée par
 * l'appel à Mistral.
 */
class CreateDossierProcessor implements ProcessorInterface
{
    public function __construct(
        #[Autowire(service: 'api_platform.doctrine.orm.state.persist_processor')]
        private ProcessorInterface $persistProcessor,
        private MessageBusInterface $bus,
        private Security $security,
    ) {}

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): mixed
    {
        // Le propriétaire est l'utilisateur authentifié (jamais fourni par le client),
        // et un dossier créé via l'API est directement SOUMIS.
        if ($data instanceof Dossier) {
            $user = $this->security->getUser();
            if ($user instanceof User) {
                $data->setProprietaire($user);
            }
            $data->setStatut(StatutDossier::SOUMIS);
        }

        // Persistance + flush par le processor par défaut (le dossier obtient son id).
        $result = $this->persistProcessor->process($data, $operation, $uriVariables, $context);

        // Déclenche la classification IA en arrière-plan, seulement s'il y a
        // une description à classer.
        if ($result instanceof Dossier && $result->getId() !== null && $result->getDescription()) {
            $this->bus->dispatch(new ClassifyDossierMessage($result->getId()));
        }

        return $result;
    }
}
