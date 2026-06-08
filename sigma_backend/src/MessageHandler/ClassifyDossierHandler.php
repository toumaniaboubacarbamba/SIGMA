<?php

namespace App\MessageHandler;

use App\Message\ClassifyDossierMessage;
use App\Repository\DossierRepository;
use Doctrine\ORM\EntityManagerInterface;
use Psr\Log\LoggerInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;
use Symfony\Contracts\HttpClient\HttpClientInterface;

/**
 * Appelle le microservice IA (FastAPI) pour classer un dossier, puis stocke
 * la catégorie prédite et le score de confiance sur l'entité.
 *
 * Exécuté en arrière-plan via Messenger (transport async). Calqué sur
 * SendNotificationHandler pour l'appel HTTP serveur-à-serveur.
 */
#[AsMessageHandler]
class ClassifyDossierHandler
{
    public function __construct(
        private DossierRepository $dossierRepository,
        private EntityManagerInterface $em,
        private HttpClientInterface $httpClient,
        private LoggerInterface $logger,
        #[Autowire('%env(IA_SERVICE_URL)%')]
        private string $iaServiceUrl,
    ) {}

    public function __invoke(ClassifyDossierMessage $message): void
    {
        $dossier = $this->dossierRepository->find($message->getDossierId());

        // Le dossier a pu être supprimé entre le dispatch et le traitement,
        // ou n'avoir aucune description à classer : on s'arrête proprement.
        if ($dossier === null || !$dossier->getDescription()) {
            return;
        }

        $url = rtrim($this->iaServiceUrl, '/') . '/classify';

        try {
            $response = $this->httpClient->request('POST', $url, [
                'json' => ['description' => $dossier->getDescription()],
                'timeout' => 40, // > timeout Mistral du microservice (30s)
            ]);

            // toArray() lève une exception sur un statut HTTP non-2xx,
            // ce qui déclenchera le retry Messenger.
            $data = $response->toArray();
        } catch (\Throwable $e) {
            $this->logger->error(sprintf(
                'Classification IA échouée pour le dossier #%d : %s',
                $dossier->getId(),
                $e->getMessage(),
            ));
            // On relance : Messenger réessaiera (max_retries: 3, multiplier: 2).
            throw $e;
        }

        $dossier->setCategorieIa($data['categorie'] ?? null);
        $dossier->setScoreConfianceIa(
            isset($data['score_confiance']) ? (float) $data['score_confiance'] : null
        );

        $this->em->flush();

        $this->logger->info(sprintf(
            'Dossier #%d classé : %s (confiance %.2f)',
            $dossier->getId(),
            $dossier->getCategorieIa() ?? 'AUTRE',
            $dossier->getScoreConfianceIa() ?? 0.0,
        ));
    }
}
