<?php

namespace App\MessageHandler;

use App\Message\SendNotificationMessage;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

#[AsMessageHandler]
class SendNotificationHandler
{
    private string $credentialsPath;

    public function __construct()
    {
        $this->credentialsPath = dirname(__DIR__, 2) . '/config/secrets/firebase.json';
    }

    public function __invoke(SendNotificationMessage $message): void
    {
        $credentials = json_decode(file_get_contents($this->credentialsPath), true);
        $projectId = $credentials['project_id'];

        $client = new \Google\Client();
        $client->setAuthConfig($this->credentialsPath);
        $client->addScope('https://www.googleapis.com/auth/firebase.messaging');

        $httpClient = $client->authorize();

        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

        $payload = [
            'message' => [
                'token' => $message->getDeviceToken(),
                'notification' => [
                    'title' => $message->getTitle(),
                    'body' => $message->getBody(),
                ],
                'data' => array_map('strval', $message->getData()),
            ]
        ];

        $httpClient->request('POST',$url, [
            'json' => $payload
        ]);
    }
}
